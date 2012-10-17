indexing
	description:

		"Output as XML files"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 00:03:22 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2552 $"

class EDOC_XML_OUTPUT

inherit

	EDOC_OUTPUT

	EDOC_SHARED_XML_CONTEXT
		export {NONE} all end

create

	make

feature {NONE} -- Initialisation

	make is
			-- Initialise default values.
		do
			default_options_filename := "options.xml.default"
		ensure
			default_options_filename_set: default_options_filename /= Void
		end

feature -- File creation

	options_file (a_filename: STRING): EDOC_OPTIONS_FILE is
			-- Create options file for html output.
		do
			create {EDOC_XML_OPTIONS_FILE}Result.make_from_filename (a_filename)
		end

	generate_cluster_file (a_cluster: ET_CLUSTER) is
			-- Generate file for `a_cluster' in 'output_directory'.
		local
			a_cluster_file: EDOC_XML_CLUSTER_FILE
		do
			create a_cluster_file.make (file_system.pathname (output_directory, xml_context.cluster_file_name (a_cluster)))
			a_cluster_file.set_cluster (a_cluster)
			xml_context.setup_cluster_page_links (a_cluster)
			a_cluster_file.generate
		end

	generate_class_file (a_class: ET_CLASS) is
			-- Generate file for `a_class' in 'output_directory'.
		local
			a_class_file: EDOC_XML_CLASS_FILE
		do
			create a_class_file.make (file_system.pathname (output_directory, xml_context.class_file_name (a_class)))
			a_class_file.set_class (a_class)
			xml_context.setup_class_page_links (a_class)
			a_class_file.generate
		end

	generate_usage_file (a_class: ET_CLASS) is
			-- Generate usage file for `a_class' in `output_directory'.
		local
			filename: STRING
		do
			filename := file_system.pathname (output_directory, "usage."+a_class.name.name.as_lower+".xml")
			-- TODO: generate usage file
		end

	generate_classes_file (a_class_list: DS_LIST [ET_CLASS]) is
			-- Generate file for `a_class_list' in `output_directory'.
		local
			a_classes_file: EDOC_XML_CLASSES_FILE
		do
			create a_classes_file.make (file_system.pathname (output_directory, xml_context.classes_file_name))
			xml_context.setup_classes_page_links
			a_classes_file.generate
		end

	generate_clusters_file (a_clusters_list: DS_LIST [ET_CLUSTER]) is
			-- Generate file for `a_clusters_list' in `output_directory'.
		local
			a_clusters_file: EDOC_XML_CLUSTERS_FILE
		do
			create a_clusters_file.make (file_system.pathname (output_directory, xml_context.clusters_file_name))
			xml_context.setup_clusters_page_links
			a_clusters_file.generate
		end

	generate_index (an_index_list: DS_LIST [EDOC_INDEX_ENTRY]) is
			-- Generate index for `an_index_list' in `output_directory'.
		local
			an_index_file: EDOC_XML_INDEX_FILE
			a_letter: CHARACTER
		do
			xml_context.setup_index_page_links
			from a_letter := 'a' until a_letter > 'z' loop
				create an_index_file.make (file_system.pathname (output_directory, xml_context.index_file_name (a_letter)))
				an_index_file.set_letter (a_letter)
				an_index_file.generate
				a_letter := a_letter.next
			end
			if Options.is_index_all_generated then
				create an_index_file.make (file_system.pathname (output_directory, xml_context.index_all_file_name))
				an_index_file.set_letter ('%U')
				an_index_file.generate
			end
		end

	generate_overview is
			-- Generate overview in `output_directory'.
		local
			overview_file: EDOC_XML_OVERVIEW_FILE
		do
			create overview_file.make (file_system.pathname (output_directory, xml_context.overview_file_name))
			xml_context.setup_overview_page_links
			overview_file.generate
		end

	generate_additional_files is
			-- Generate additional files needed for output.
		do
			file_system.copy_file (Options.original_xsd_file, file_system.pathname (output_directory, xml_context.xsd_file_name))
		end

end
