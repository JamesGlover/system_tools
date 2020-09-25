
require 'pathname'

class GitRepo
  MAIN_BRANCH_PRIORITY = %w[develop development master next_release production release]

  def self.with_repo(recursive: false, path: Pathname.getwd, &block)
    each_directory(path, recursive) do |directory|
      yield GitRepo.new(directory) if is_git?(directory)
    end
  end

  def self.each_directory(path, recursive, &block)
    if recursive
      path.each_child(&block)
    else
      path.tap(&block)
    end
  end

  def self.is_git?(directory)
    directory.directory? && directory.glob('.git').any?
  end

  # Hacky hardcoding while I migrate
  def syncable?
    with_path do
      `git remote get-url sanger`.downcase.start_with?('git@github.com:sanger') &&
      `git remote get-url origin`.downcase.start_with?('git@github.com:jamesglover') &&
      `git status --porcelain`.empty?
    end
  end

  def pushable?
    with_path do
      `git remote get-url origin`.downcase.start_with?('git@github.com:jamesglover')
    end
  end

  def sync
    if syncable?
      log "Syncing #{repo_name}"
      branches_to_sync.each do |branch|
        with_path do
          `git checkout #{branch}` &&
          `git pull sanger #{branch}` &&
          `git push origin #{branch}`
        end
      end
    else
      warn "Can't Sync #{repo_name}"
    end
  end

  def backup
    if pushable?
      log "Pushing #{repo_name} to origin"
      with_path { `git push origin --all` }
    else
      warn "Can't backup #{repo_name}"
    end
  end

  def branches_to_sync
    (branches & MAIN_BRANCH_PRIORITY)
  end

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
    ║ Repo: #{repo_name} #{syncable? ? 'S' : 'x'}#{pushable? ? 'P' : 'x'}
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

  def cleanup(force = false)
    flag = force ? 'D' : 'd'
    log "Cleaning #{repo_name}..."
    merged_branches.each do |branch|
      next if protected_branch?(branch)
      log "Deleting #{branch}"
      with_path { log `git branch -#{flag} #{branch}` }
    end
  end

  private

  def log(message)
    $stdout.puts message
  end

  def warn(message)
    $stderr.puts "\u001b[31m#{message}\u001b[0m"
  end

  def protected_branch?(name)
    MAIN_BRANCH_PRIORITY.include?(name)
  end

  def with_path(&block)
    Dir.chdir(@path, &block)
  end
end
