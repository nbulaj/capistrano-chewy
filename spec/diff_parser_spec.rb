require 'spec_helper'

describe CapistranoChewy::DiffParser do
  let(:current_path) { File.expand_path('../stub/chewy_current', __FILE__) }
  let(:release_path) { File.expand_path('../stub/chewy_release', __FILE__) }

  let(:full_diff) { `diff -qZEB #{current_path} #{release_path}` }

  describe '#parse' do
    context 'with difference between directories' do
      it 'returns result object with removed, added and changed files' do
        result = described_class.parse(full_diff, current_path, release_path)

        expect(result.changed).to match_array(["#{release_path}/accounts_index.rb", "#{release_path}/posts_index.rb", "#{release_path}/comments_index.rb"])
        expect(result.added).to eq(["#{release_path}/applications_index.rb"])
        expect(result.removed).to eq(["#{current_path}/users_index.rb"])

        expect(result.empty?).to be_falsey
      end
    end

    context 'without differences' do
      it 'returns result object with removed, added and changed files' do
        result = described_class.parse('', current_path, release_path)

        expect(result.changed).to be_empty
        expect(result.added).to be_empty
        expect(result.removed).to be_empty

        expect(result.empty?).to be_truthy
      end
    end

    context 'with the same directories' do
      it 'returns blank result' do
        result = described_class.parse('', current_path, current_path)

        expect(result.changed).to be_empty
        expect(result.added).to be_empty
        expect(result.removed).to be_empty

        expect(result.empty?).to be_truthy
      end
    end
  end
end
