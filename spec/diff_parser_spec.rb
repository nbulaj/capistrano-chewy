require 'spec_helper'

describe CapistranoChewy::DiffParser do
  let(:current_path) { '/project/1/app/chewy' }
  let(:release_path) { '/project/2/app/chewy' }

  let(:full_diff) do
    "Files #{current_path}/accounts_index.rb and #{release_path}/accounts_index.rb differ\n" \
    "Files #{current_path}/posts_index.rb and #{release_path}/posts_index.rb differ\n" \
    "Only in #{release_path}: applications_index.rb\n" \
    "Files #{current_path}/comments_index.rb and #{release_path}/comments_index.rb differ\n" \
    "Only in #{current_path}: users_index.rb\n"
  end

  describe '#parse' do
    context 'with difference between directories' do
      it 'returns result object with removed, added and changed files' do
        result = described_class.parse(full_diff, current_path, release_path)

        expect(result.changed).to eq(["#{release_path}/accounts_index.rb", "#{release_path}/posts_index.rb", "#{release_path}/comments_index.rb"])
        expect(result.added).to eq(["#{release_path}/applications_index.rb"])
        expect(result.removed).to eq(["#{current_path}/users_index.rb"])
      end
    end

    context 'without differences' do
      it 'returns result object with removed, added and changed files' do
        result = described_class.parse('', current_path, release_path)

        expect(result.changed).to be_empty
        expect(result.added).to be_empty
        expect(result.removed).to be_empty
      end
    end

    context 'with the same directories' do
      it 'raises an error' do
        expect { described_class.parse('', current_path, current_path) }.to raise_error(ArgumentError)
      end
    end
  end
end
