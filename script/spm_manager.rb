#
# © 2026-present https://github.com/cengiz-pz
#

require 'xcodeproj'

def print_usage
	puts "Usage: ruby spm_manager.rb -a|-d <path_to_xcodeproj> <url> <version> <product_name>"
	puts ""
	puts "Options:"
	puts "  -a    Add the specified SPM dependency to the Xcode project"
	puts "  -d    Remove the specified SPM dependency from the Xcode project"
	puts ""
	puts "Examples:"
	puts "  ruby spm_manager.rb -a MyProject.xcodeproj https://github.com/URL 1.0.0 ProductName"
	puts "  ruby spm_manager.rb -d MyProject.xcodeproj https://github.com/URL 1.0.0 ProductName"
end

# Argument Validation
if ARGV.length != 5
	print_usage
	exit 1
end

option       = ARGV[0]
project_path = ARGV[1]
url          = ARGV[2].strip
version      = ARGV[3].strip
product_name = ARGV[4].strip

unless ['-a', '-d'].include?(option)
	puts "Error: Unknown option '#{option}'. Must be -a (add) or -d (remove)."
	puts ""
	print_usage
	exit 1
end

unless File.exist?(project_path)
	puts "Error: Xcode project not found at #{project_path}"
	exit 1
end

if url.empty? || version.empty? || product_name.empty?
	puts "Error: url, version, and product_name must all be non-empty."
	exit 1
end

# Xcode Project Manipulation
begin
	project = Xcodeproj::Project.open(project_path)
	target = project.targets.first

	if target.nil?
		puts "Error: No targets found in the Xcode project."
		exit 1
	end

	if option == '-a'
		# Check for an existing product dependency with the same name to avoid duplicates
		existing_dep = target.package_product_dependencies.find do |dep|
			dep.product_name == product_name
		end

		if existing_dep
			puts "Warning: Product dependency '#{product_name}' already exists in the project. Skipping add.\n\n"
		else
			# Reuse an existing package reference for the same URL, or create a new one
			pkg = project.root_object.package_references.find do |p|
				p.repositoryURL == url
			end

			if pkg
				puts "Reusing existing package reference for '#{url}'."
			else
				pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
				pkg.repositoryURL = url
				pkg.requirement = {
					'kind' => 'upToNextMajorVersion',
					'minimumVersion' => version
				}
				project.root_object.package_references << pkg
			end

			# Create the product dependency and link it to the shared package reference
			ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
			ref.product_name = product_name
			ref.package = pkg
			target.package_product_dependencies << ref

			puts "Successfully added SPM dependency '#{product_name}' (#{url} @ #{version}) to #{File.basename(project_path)}\n\n"
		end

	elsif option == '-d'
		# Remove the product dependency from the target
		dep_to_remove = target.package_product_dependencies.find do |dep|
			dep.product_name == product_name
		end

		if dep_to_remove
			target.package_product_dependencies.delete(dep_to_remove)
			dep_to_remove.remove_from_project
			puts "Removed product dependency '#{product_name}'."
		else
			puts "Warning: Product dependency '#{product_name}' not found in target. Skipping.\n\n"
		end

		# Only remove the package reference if no remaining product dependencies still point to it
		pkg_to_remove = project.root_object.package_references.find do |pkg|
			pkg.repositoryURL == url
		end

		if pkg_to_remove
			still_in_use = target.package_product_dependencies.any? do |dep|
				dep.package == pkg_to_remove
			end

			if still_in_use
				puts "Package reference '#{url}' is still used by other products. Keeping it.\n\n"
			else
				project.root_object.package_references.delete(pkg_to_remove)
				pkg_to_remove.remove_from_project
				puts "Removed package reference '#{url}'.\n\n"
			end
		else
			puts "Warning: Package reference '#{url}' not found in project. Skipping.\n\n"
		end

		puts "Successfully removed SPM dependency '#{product_name}' from #{File.basename(project_path)}\n\n"
	end

	project.save

rescue => e
	puts "An error occurred: #{e.message}\n\n"
	exit 1
end
