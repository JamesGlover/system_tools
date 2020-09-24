
class GitRepo
  MAIN_BRANCH_PRIORITY = %w[develop master next_release production release]

  def initialize(path)
    @path = path
  end

  def main_branch
    branches.min_by { |name| MAIN_BRANCH_PRIORITY.index(name) || 999 }
  end

  def repo_name
    @path.basename
  end

  def remotes
    with_path { `git remote`.split }
  end

  def branches(branch_args = '')
    with_path do
      `git branch #{branch_args}`.lines.map { |branch| branch.chomp.tr('* ','') }
    end
  end

  def commit_count
    with_path { `git rev-list HEAD --count`.chomp }
  end

  def report
    <<~REPORT
    ╔═══════════════════════════════════════════════════════════════════════════════
    ║ Repo: #{repo_name}
    ╠═══════════════════════════════════════════════════════════════════════════════
    ║ Remotes: #{remotes.join(', ')}
    ║ Branches: #{branches.length}
    ║ Main branch: #{main_branch}
    ║ Commits: #{commit_count}
    ╚═══════════════════════════════════════════════════════════════════════════════
    REPORT
  end

  def merged_branches
    branches("--merged #{main_branch}")
  end

  def cleanup
    puts "Cleaning #{repo_name}..."
    merged_branches.each do |branch|
      next if protected_branch?(branch)
      puts "Deleting #{branch}"
      with_path { puts `git branch -d #{branch}` }
    end
  end

  private

  def protected_branch?(name)
    MAIN_BRANCH_PRIORITY.include?(name)
  end

  def with_path(&block)
    Dir.chdir(@path, &block)
  end
end
