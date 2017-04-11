namespace :load do
  task :defaults do
    set :chewy_default_hooks, -> { true }
    set :chewy_conditionally_reset, -> { true }
    set :chewy_path, -> { 'app/chewy' }
    set :chewy_env, -> { fetch(:rails_env, fetch(:stage)) }
    set :chewy_role, -> { :app }
    set :chewy_delete_removed_indexes, -> { true }
    set :chewy_apply_journal, -> { false }
  end
end

namespace :deploy do
  before :starting, :check_chewy_hooks do
    invoke :'chewy:add_default_hooks' if fetch(:chewy_default_hooks)
  end
end

namespace :chewy do
  def capture_runner(ruby_code)
    within release_path do
      with rails_env: fetch(:chewy_env) do
        return capture :rails, "runner \"#{ruby_code}\""
      end
    end
  end

  def journal_exists?
    capture_runner('puts Chewy::Journal.exists?') == 'true'
  end

  # Chewy supports journaling currently only in master
  def support_journaling?(chewy_version)
    Gem::Dependency.new('', '> 0.8.4').match?('', chewy_version)
  end

  def apply_journal_changes_from(time_in_seconds)
    raise ArgumentError, 'argument must be an integer!' unless time_in_seconds.is_a?(Integer)

    unless support_journaling?
      warn <<-MSG.strip
          Your Chewy version doesn't support journaling. Disable :chewy_apply_journal option or update Chewy gem (>= 0.9).
      MSG
      return
    end

    unless journal_exists?
      warn "Chewy Journal doesn't exists. Journaling is enabled in the settings?"
      return
    end

    within release_path do
      with rails_env: fetch(:chewy_env) do
        info "Applying journal changes from #{Time.zone.at(time_in_seconds).strftime('%T %D %z')}"
        execute :rails, "runner 'Chewy::Journal.apply_changes_from(Time.zone.at(#{time_in_seconds})'"
      end
    end
  end

  def delete_indexes(index_files)
    index_classes = index_files.map { |file| File.basename(file, '.rb').camelize }.uniq
    runner_code = "[#{index_classes.join(', ')}].each(&:delete)"

    # Removed index files exists only in the old (current) release
    within current_path do
      with rails_env: fetch(:chewy_env) do
        info "Removing indexes: #{index_classes.join(',')}"
        execute :rails, "runner '#{runner_code}'"
      end
    end
  end

  def reset_modified_indexes(index_files)
    index_names = index_files.map { |file| File.basename(file, '_index.rb') }.join(',')

    within release_path do
      with rails_env: fetch(:chewy_env) do
        info "Modified or new indexes: #{index_names}"
        execute :rake, "chewy:reset[#{index_names}]"
      end
    end
  end

  def run_default_chewy_task(task_name, indexes)
    on roles fetch(:chewy_role) do
      within release_path do
        with rails_env: fetch(:chewy_env) do
          if indexes.any?
            execute :rake, "chewy:#{task_name}[#{indexes.join(',')}]"
          else
            # Simply chewy:reset / chewy:update for Chewy > 0.8.4
            execute :rake, "chewy:#{task_name}"
          end
        end
      end
    end
  end

  # Adds default Capistrano::Chewy hooks to the deploy flow
  task :add_default_hooks do
    after :'deploy:updated', 'chewy:rebuild'
    after :'deploy:reverted', 'chewy:rebuild'
  end

  # Default Chewy rake tasks
  desc 'Destroy, recreate and import data to all or specified (pass with [one,two]) indexes'
  task :reset do |_task, args|
    run_default_chewy_task(:reset, args.extras)
  end

  desc 'Updates data to all or specified (passed with [one,two]) indexes'
  task :update do |_task, args|
    run_default_chewy_task(:update, args.extras)
  end

  # Smart rebuild of modified Chewy indexes
  desc 'Reset Chewy indexes if they have been added, changed or removed'
  task :rebuild do
    on roles fetch(:chewy_role) do
      info "Checking Chewy directory (#{fetch(:chewy_path)})"

      chewy_path = File.join(release_path, fetch(:chewy_path))
      unless test("[ -d #{chewy_path} ]")
        error "Directory #{chewy_path} doesn't exist!"
        exit 1
      end

      if fetch(:chewy_conditionally_reset)
        if test('diff -v')
          info 'Running smart indexes reset...'
          invoke :'chewy:rebuilding'
        else
          error "Can't check the difference between Chewy indexes - install 'diff' tool first!"
          exit 1
        end
      else
        info 'Running chewy:reset'
        invoke :'chewy:reset'
      end
    end
  end

  desc 'Runs smart Chewy indexes rebuilding (only for changed files)'
  task :rebuilding do
    on roles fetch(:chewy_role) do
      rebuilding_started_at = capture_runner('Time.current.to_i')

      chewy_path = fetch(:chewy_path)
      info "Checking changes in #{chewy_path}"

      chewy_release_path = File.join(release_path, chewy_path)
      chewy_current_path = File.join(current_path, chewy_path)

      # -q, --brief                     report only when files differ
      # -E, --ignore-tab-expansion      ignore changes due to tab expansion
      # -Z, --ignore-trailing-space     ignore white space at line end
      # -B, --ignore-blank-lines        ignore changes where lines are all blank
      #
      diff_args = "-qZEB #{chewy_release_path} #{chewy_current_path}"
      indexes_diff = capture :diff, diff_args, raise_on_non_zero_exit: false
      changes = ::CapistranoChewy::DiffParser.parse(indexes_diff, chewy_current_path, chewy_release_path)

      # If diff is empty then indices have not changed
      if changes.empty?
        info 'Skipping `chewy:rebuilding` (nothing changed in the Chewy path)'
      else
        indexes_to_reset = changes.changed.concat(changes.added)
        indexes_to_delete = changes.removed

        # Reset indexes which have been modified or added
        reset_modified_indexes(indexes_to_reset) if indexes_to_reset.any?

        # Apply changes from journal that affected after index reset
        apply_journal_changes_from(rebuilding_started_at) if fetch(:chewy_apply_journal)

        # Delete indexes which have been removed
        if indexes_to_delete.any? && fetch(:chewy_delete_removed_indexes)
          delete_indexes(indexes_to_delete)
        end
      end
    end
  end
end
