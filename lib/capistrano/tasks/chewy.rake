namespace :load do
  task :defaults do
    set :chewy_conditionally_reset, -> { true }
    set :chewy_path, -> { 'app/chewy' }
    set :chewy_env, -> { fetch(:rails_env, fetch(:stage)) }
    set :chewy_role, -> { :app }
    set :chewy_skip, -> { false }
  end
end

namespace :deploy do
  namespace :chewy do
    # Default Chewy rake tasks
    desc 'Destroy, recreate and import data to all or specified indexes'
    task :reset do |_task, args|
      indexes = args.extras

      on roles fetch(:chewy_role) do
        within release_path do
          with rails_env: fetch(:chewy_env) do
            if indexes.any?
              execute :rake, "chewy:reset[#{indexes.join(',')}]"
            else
              # Simply chewy:reset / chewy:update for Chewy > 0.8.4
              execute :rake, 'chewy:reset:all'
            end
          end
        end
      end
    end

    desc 'Updates data to all or specified indexes'
    task :update do |_task, args|
      indexes = args.extras

      on roles fetch(:chewy_role) do
        within release_path do
          with rails_env: fetch(:chewy_env) do
            if indexes.any?
              execute :rake, "chewy:update[#{indexes.join(',')}]"
            else
              execute :rake, 'chewy:update:all'
            end
          end
        end
      end
    end

    # Smart rebuild of modified indexes
    desc 'Reset Chewy indexes if they have been added, changed or removed'
    task :rebuild do
      on roles fetch(:chewy_role) do
        if fetch(:chewy_skip)
          info '[deploy:chewy:rebuild] Skipping task according to the deploy settings'
          exit 0
        end

        info '[deploy:chewy:rebuild] Checking Chewy directory'

        chewy_path = File.join(release_path, fetch(:chewy_path))
        unless test("[ -d #{chewy_path} ]")
          error "Directory #{chewy_path} doesn't exist!"
          exit 1
        end

        if fetch(:chewy_conditionally_reset)
          if test('diff -v')
            info '[deploy:chewy:rebuild] Run smart index reset'
            invoke :'deploy:chewy:rebuilding'
          else
            error "Can't check the difference between Chewy indexes - install 'diff' tool first!"
            exit 1
          end
        else
          info '[deploy:chewy:rebuild] Run chewy:reset:all'
          invoke :'deploy:chewy:reset:all'
        end
      end
    end

    desc 'Runs smart Chewy indexes rebuilding (only for changed files)'
    task :rebuilding do
      on roles fetch(:chewy_role) do
        if fetch(:chewy_skip)
          info '[deploy:chewy:rebuilding] Skipping task according to the deploy settings'
          exit 0
        end

        chewy_path = fetch(:chewy_path)
        info "[deploy:chewy:rebuilding] Checking changes in #{chewy_path}"

        chewy_release_path = File.join(release_path, chewy_path)
        chewy_current_path = File.join(current_path, chewy_path)

        # -q, --brief                     report only when files differ
        # -E, --ignore-tab-expansion      ignore changes due to tab expansion
        # -Z, --ignore-trailing-space     ignore white space at line end
        # -B, --ignore-blank-lines        ignore changes where lines are all blank
        #
        indexes_diff = capture :diff, "-qZEB #{chewy_release_path} #{chewy_current_path}"

        # If diff is empty then indices have not changed
        if indexes_diff.nil? || indexes_diff.strip.empty?
          info '[deploy:chewy:rebuilding] Skipping `deploy:rebuilding` (nothing changed in the Chewy path)'
        else
          within release_path do
            with rails_env: fetch(:chewy_env) do
              changes = ::CapistranoChewy::DiffParser.parse(indexes_diff, chewy_current_path, chewy_release_path)

              # Reset indexes that were changed or added
              indexes_to_reset = changes.changed.concat(changes.added)

              if indexes_to_reset.any?
                indexes = indexes_to_reset.map { |file| File.basename(file).gsub('_index.rb', '') }.join(',')
                execute :rake, "chewy:reset[#{indexes}]"
              end
            end
          end
        end
      end
    end
  end

  after 'deploy:updated', 'deploy:chewy:rebuild'
end
