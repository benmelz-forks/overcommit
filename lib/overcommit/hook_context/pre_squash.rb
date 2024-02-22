# frozen_string_literal: true

require 'set'
require_relative 'helpers/stash_unstaged_changes'
require_relative 'helpers/file_modifications'

module Overcommit::HookContext
  # Simulates a pre-commit context pretending that all files have been changed.
  #
  # This results in pre-commit hooks running against the entire repository,
  # which is useful for automated CI scripts.
  class PreSquash < Base
    def refs
      @args
    end

    # Get a list of added, copied, or modified files that have been staged.
    # Renames and deletions are ignored, since there should be nothing to check.
    def modified_files
      @modified_files ||= Overcommit::GitRepo.modified_files(refs: refs)
    end

    # Returns the set of line numbers corresponding to the lines that were
    # changed in a specified file.
    def modified_lines_in_file(file)
      @modified_lines ||= {}
      @modified_lines[file] ||= Overcommit::GitRepo.extract_modified_lines(file, refs: refs)
    end

    def hook_class_name
      'PreCommit'
    end

    def hook_type_name
      'pre_commit'
    end

    def hook_script_name
      'pre-commit'
    end
  end
end
