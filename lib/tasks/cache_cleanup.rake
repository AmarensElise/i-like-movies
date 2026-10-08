namespace :tmp do
  desc "Delete stale files from tmp/cache (safety net; keeps bootsnap and assets). AGE_MINUTES=60 by default"
  task cleanup_cache: :environment do
    age = Integer(ENV.fetch("AGE_MINUTES", 60)) * 60
    cutoff = Time.now - age
    root = Rails.root.join("tmp", "cache")
    keep = %w[bootsnap assets].map { |d| root.join(d).to_s }
    deleted = 0

    Dir.glob(root.join("**", "*"), File::FNM_DOTMATCH).each do |path|
      next if keep.any? { |k| path == k || path.start_with?("#{k}/") }
      next unless File.file?(path) && File.mtime(path) < cutoff

      File.delete(path)
      deleted += 1
    rescue Errno::ENOENT
      next
    end

    # remove now-empty directories, deepest first
    Dir.glob(root.join("**", "*")).select { |p| File.directory?(p) }.sort_by { |p| -p.length }.each do |dir|
      next if keep.any? { |k| dir == k || dir.start_with?("#{k}/") }
      Dir.rmdir(dir) if Dir.empty?(dir)
    rescue SystemCallError
      next
    end

    puts "Deleted #{deleted} files older than #{age / 60} minutes from #{root}"
  end
end
