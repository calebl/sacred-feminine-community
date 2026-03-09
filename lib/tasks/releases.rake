namespace :releases do
  desc "Record a release from deploy hook data"
  task :record, [ :version, :commit_sha, :changelog, :deployed_at ] => :environment do |_t, args|
    changelog = args[:changelog].gsub("%%NL%%", "\n")

    release = Release.create!(
      version: args[:version],
      commit_sha: args[:commit_sha],
      changelog: changelog,
      deployed_at: args[:deployed_at]
    )
    puts "Recorded release #{release.version} (#{release.commit_sha[0..7]})"
  end
end
