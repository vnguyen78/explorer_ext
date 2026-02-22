require 'xcodeproj'
project_path = '/Users/admin/Downloads/prj/exp_txt_view/explore_txt_view/explore_txt_view.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

['explore_txt_view/marked.min.js', 'explore_txt_view/mermaid.min.js'].each do |file_path|
  name = File.basename(file_path)
  group = project.main_group.find_subpath('explore_txt_view', false)
  
  # Check if exists
  existing = group.files.find { |f| f.path == name }
  unless existing
    file_ref = group.new_reference(name)
    target.resources_build_phase.add_file_reference(file_ref)
    puts "Added #{name} to resources."
  end
end
project.save
