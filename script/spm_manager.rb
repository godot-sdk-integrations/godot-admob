#
# © 2026-present https://github.com/cengiz-pz
#

require 'xcodeproj'

# Argument Validation
if ARGV.length < 2
	puts "Usage: ruby spm_manager.rb <path_to_xcodeproj> <dependency1> [dependency2 ...]"
	puts "Example: ruby spm_manager.rb MyProject.xcodeproj \"https://github.com/URL1|Version1|ProductName1\" \"https://github.com/URL2|Version2|ProductName2\""
	exit 1
end

project_path = ARGV[0]
deps = ARGV[1..-1]

unless File.exist?(project_path)
	puts "Error: Xcode project not found at #{project_path}"
	exit 1
end

# Xcode Project Manipulation
begin
	project = Xcodeproj::Project.open(project_path)
	# Target selection logic (defaults to the first target)
	target = project.targets.first

	if target.nil?
		puts "Error: No targets found in the Xcode project."
		exit 1
	end

	# Clear existing SPM packages to avoid duplicates on rebuilds
	project.root_object.package_references.clear
	target.package_product_dependencies.clear

	# Dynamically inject SPM dependencies
	deps.each do |dep|
		next if dep.empty?
		# Expected format: "https://github.com/URL|Version|ProductName"
		parts = dep.split('|').map(&:strip)

		if parts.size == 3
			url, version, product_name = parts

			# Create the remote SPM package reference
			pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
			pkg.repositoryURL = url
			pkg.requirement = {
				'kind' => 'upToNextMajorVersion',
				'minimumVersion' => version
			}
			project.root_object.package_references << pkg

			# Create the product dependency and link it to the target
			ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
			ref.product_name = product_name
			ref.package = pkg
			target.package_product_dependencies << ref
		else
			puts "Warning: Skipping invalid SPM dependency format: #{dep}. Expected 'URL|Version|ProductName'\n\n"
		end
	end

	project.save
	puts "Successfully updated SPM dependencies in #{File.basename(project_path)}\n\n"

rescue => e
	puts "An error occurred: #{e.message}\n\n"
	exit 1
end
