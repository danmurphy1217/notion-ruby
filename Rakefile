desc "Remove unnecessary files"
task :clean do
    all_entries = Dir.entries(".")
    dirs = []
    all_entries.each {|f| File.file?(f) ? nil: dirs.push(f)}
    dirs.each {|dir| get_all_files(dir)}
end

def get_all_files(folder)
    p Dir.entries(folder)
end