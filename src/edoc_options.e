indexing

	description:

		"Various options for input, output and parser"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_OPTIONS

create

	make

feature {NONE} -- Initialisation

	make is
			-- Initialise context.
		do
			output_directory := "output"
			create {DS_LINKED_LIST [STRING]}ignored_indexing_tags.make_equal
			create {DS_LINKED_LIST [STRING]}feature_clause_order.make_equal
			create {DS_LINKED_LIST [STRING]}ignored_inherit_classes.make_equal
			create {DS_LINKED_LIST [STRING]}ignored_feature_clauses.make_equal
			title := Void
			short_title := Void
			version := ""
			original_css_file := ""
			original_xsd_file := ""
			create {DS_LINKED_LIST [STRING]}ignored_clusters.make_equal
			create {DS_LINKED_LIST [STRING]}mounted_libraries.make_equal
			create {DS_LINKED_LIST [STRING]}dummy_classes.make_equal
		end

feature -- Access (Input)

	ignored_clusters: DS_LIST [STRING]
			-- Ignored clusters (subclusters are ignored also)

	ace_file: STRING
			-- Input ace file

	xace_library: STRING
			-- XAce file of library

	xace_system: STRING
			-- XAce file of system

	mounted_libraries: DS_LIST [STRING]
			-- XAce files of mounted libraries

feature -- Status report (Input)

	are_mounted_libraries_included: BOOLEAN
			-- Are mounted libraries included?

feature -- Status setting (Input)

	set_mounted_libraries_included (a_value: like are_mounted_libraries_included) is
			-- Set `are_mounted_libraries_included' to `a_value'.
		do
			are_mounted_libraries_included := a_value
		ensure
			are_mounted_libraries_included_set: are_mounted_libraries_included = a_value
		end

feature -- Element change (Input)

	set_ace_file (a_file: like ace_file) is
			-- Set `ace_file' to `a_file'.
		require
			a_file_not_void: a_file /= Void
		do
			ace_file := a_file
		ensure
			ace_file_set: ace_file = a_file
		end

	set_xace_library (a_file: like xace_library) is
			-- Set `xace_library' to `a_file'.
		require
			a_file_not_void: a_file /= Void
		do
			xace_library := a_file
		ensure
			xace_library_set: xace_library = a_file
		end

	set_xace_system (a_file: like xace_system) is
			-- Set `xace_system' to `a_file'.
		require
			a_file_not_void: a_file /= Void
		do
			xace_system := a_file
		ensure
			xace_system_set: xace_system = a_file
		end

feature -- Access (Output)

	output_directory: STRING
			-- Output directory

feature -- Status report (Output)

	is_output_flat: BOOLEAN
			-- Is output flat?
			-- Yes means all files will be in the same directory.
			-- No means a directory structure similar to the cluster structure is used.

	is_feature_list_generated: BOOLEAN
			-- Is a features list generated?

	is_ancestors_list_generated: BOOLEAN
			-- Is an ancestors list generated?

	is_descendants_list_generated: BOOLEAN
			-- Is a descendants list generated?

	is_inherit_tree_generated: BOOLEAN
			-- Is an inheritance tree generated?

	are_cluster_files_generated: BOOLEAN
			-- Are cluster files generated?

	is_index_generated: BOOLEAN
			-- Is an index generated?

	is_index_all_generated: BOOLEAN
			-- Is a single index over everything generated?

	are_usage_files_generated: BOOLEAN
			-- Are usage files generated?

	is_classes_file_generated: BOOLEAN
			-- Is a classes file generated?

	is_clusters_file_generated: BOOLEAN
			-- Is a clusters file generated?

	is_overview_generated: BOOLEAN
			-- Is an overview page generated?

feature -- Status setting (Output)

	set_output_flat (a_value: like is_output_flat) is
			-- Set `is_output_flat' to `a_value'.
		do
			is_output_flat := a_value
		ensure
			is_output_flat_set: is_output_flat = a_value
		end

	set_cluster_files_generated (a_value: like are_cluster_files_generated) is
			-- Set `are_cluster_files_generated' to `a_value'.
		do
			are_cluster_files_generated := a_value
		ensure
			are_cluster_files_generated_set: are_cluster_files_generated = a_value
		end

	set_index_generated (a_value: like is_index_generated) is
			-- Set `is_index_generated' to `a_value'.
		do
			is_index_generated := a_value
		ensure
			is_index_generated_set: is_index_generated = a_value
		end

	set_index_all_generated (a_value: like is_index_all_generated) is
			-- Set `is_index_all_generated' to `a_value'.
		do
			is_index_all_generated := a_value
		ensure
			is_index_all_generated_set: is_index_all_generated = a_value
		end

	set_feature_list_generated (a_value: like is_feature_list_generated) is
			-- Set `is_feature_list_generated' to `a_value'.
		do
			is_feature_list_generated := a_value
		ensure
			is_feature_list_generated_set: is_feature_list_generated = a_value
		end

	set_ancestors_list_generated (a_value: like is_ancestors_list_generated) is
			-- Set `is_ancestors_list_generated' to `a_value'.
		do
			is_ancestors_list_generated := a_value
		ensure
			is_ancestors_list_generated_set: is_ancestors_list_generated = a_value
		end

	set_descendants_list_generated (a_value: like is_descendants_list_generated) is
			-- Set `is_descendants_list_generated' to `a_value'.
		do
			is_descendants_list_generated := a_value
		ensure
			is_descendants_list_generated_set: is_descendants_list_generated = a_value
		end

	set_inherit_tree_generated (a_value: like is_inherit_tree_generated) is
			-- Set `is_inherit_tree_generated' to `a_value'.
		do
			is_inherit_tree_generated := a_value
		ensure
			is_inherit_tree_generated_set: is_inherit_tree_generated = a_value
		end

	set_usage_files_generated (a_value: like are_usage_files_generated) is
			-- Set `are_usage_files_generated' to `a_value'.
		do
			are_usage_files_generated := a_value
		ensure
			are_usage_files_generated_set: are_usage_files_generated = a_value
		end

	set_classes_file_generated (a_value: like is_classes_file_generated) is
			-- Set `is_classes_file_generated' to `a_value'.
		do
			is_classes_file_generated := a_value
		ensure
			is_classes_file_generated_set: is_classes_file_generated = a_value
		end

	set_clusters_file_generated (a_value: like is_clusters_file_generated) is
			-- Set `is_clusters_file_generated' to `a_value'.
		do
			is_clusters_file_generated := a_value
		ensure
			is_clusters_file_generated_set: is_clusters_file_generated = a_value
		end

	set_overview_generated (a_value: like is_overview_generated) is
			-- Set `is_overview_generated' to `a_value'.
		do
			is_overview_generated := a_value
		ensure
			is_overview_generated_set: is_overview_generated = a_value
		end

feature -- Element change (Output)

	set_output_direcotry (a_directory: like output_directory) is
			-- Set `output_directory' to `a_directory'.
		require
			a_directory_not_void: a_directory /= Void
		do
			output_directory := a_directory
		ensure
			output_directory_set: output_directory = a_directory
		end

feature -- Access (Parser)

	ignored_indexing_tags: DS_LIST [STRING]
			-- Ignored indexing tags

	ignored_inherit_classes: DS_LIST [STRING]
			-- Ignored inherit classes

	feature_clause_order: DS_LIST [STRING]
			-- Feature clause order

	user_defined_feature_clause_index: INTEGER
			-- Feature clause index of user defined clauses

	ignored_feature_clauses: DS_LIST [STRING]
			-- Ignored feature clauses

	dummy_classes: DS_LIST [STRING]
			-- Dummy classes to prevent inheritance problems

feature -- Status report (Parser)

	are_classes_flat: BOOLEAN
			-- Are classes in flat form?

	is_inherit_export_none_ignored: BOOLEAN
			-- Are classes ignored which are exported to NONE?

	is_feature_clause_export_none_ignored: BOOLEAN
			-- Are feature clauses ignored which are exported to NONE?

feature -- Status setting (Parser)

	set_classes_flat (a_value: like are_classes_flat) is
			-- Set `are_classes_flat' to `a_value'.
		do
			are_classes_flat := a_value
		ensure
			are_classes_flat_set: are_classes_flat = a_value
		end

	set_inherit_export_none_ignored (a_value: like is_inherit_export_none_ignored) is
			-- Set `is_inherit_export_none_ignored' to `a_value'.
		do
			is_inherit_export_none_ignored := a_value
		ensure
			is_inherit_export_none_ignored_set: is_inherit_export_none_ignored = a_value
		end

	set_feature_clause_export_none_ignored (a_value: like is_feature_clause_export_none_ignored) is
			-- Set `is_feature_clause_export_none_ignored' to `a_value'.
		do
			is_feature_clause_export_none_ignored := a_value
		ensure
			is_feature_clause_export_none_ignored_set: is_feature_clause_export_none_ignored = a_value
		end

	set_user_defined_feature_clause_index (a_value: like user_defined_feature_clause_index) is
			-- Set `is_feature_clause_export_none_ignored' to `a_value'.
		do
			user_defined_feature_clause_index := a_value
		ensure
			user_defined_feature_clause_index_set: user_defined_feature_clause_index = a_value
		end

feature -- Access

	xace_title: STRING
			-- Title of main xace-file (either system or library)

feature -- Access (HTML)

	title: STRING
			-- Documentation title

	short_title: STRING
			-- Short title

	version: STRING
			-- Version

	original_css_file: STRING
			-- Absolute path to original css file

	original_xsd_file: STRING
			-- Absolute path to xml-schema file

	is_edoc_notice_printed: BOOLEAN
			-- Is a notice about edoc printed?

	home_url: STRING
			-- Url to homepage

feature -- Element change (HTML) -- TODO: move to HTML cluster

	set_title (a_string: like title) is
			-- Set `title' to `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
			title := a_string
		ensure
			title_set: title = a_string
		end

	set_short_title (a_string: like short_title) is
			-- Set `short_title' to `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
			short_title := a_string
		ensure
			short_title_set: short_title = a_string
		end

	set_version (a_string: like version) is
			-- Set `version' to `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
			version := a_string
		ensure
			version_set: version = a_string
		end

	set_original_css_file (a_filename: like original_css_file) is
			-- Set `original_css_file' to `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		do
			original_css_file := a_filename
		ensure
			original_css_file_set: original_css_file = a_filename
		end

	set_original_xsd_file (a_filename: like original_xsd_file) is
			-- Set `original_xsd_file' to `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		do
			original_xsd_file := a_filename
		ensure
			original_xsd_file_set: original_xsd_file = a_filename
		end

	set_edoc_notice_printed (a_value: like is_edoc_notice_printed) is
			-- Set `is_edoc_notice_printed' to `a_value'.
		do
			is_edoc_notice_printed := a_value
		ensure
			is_edoc_notice_printed_set: is_edoc_notice_printed = a_value
		end

	set_home_url (a_string: like home_url) is
			-- Set `home_url' to `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
			home_url := a_string
		ensure
			home_url_set: home_url = a_string
		end

feature -- Access

	edoc_website_link: STRING is "http://eiffel.tschannen.net/edoc"
			-- Link to edoc website

feature -- Access (XML) -- TODO: move to xml-cluster

	xml_header_file: STRING
			-- Absolute path to xml-header file

	xml_footer_file: STRING
			-- Absolute path to xml-footer file

feature -- Element change (XML) -- TODO: move to xml-cluster

	set_xml_header_file (a_filename: like xml_header_file) is
			-- Set `xml_header_file' to `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		do
			xml_header_file := a_filename
		ensure
			xml_header_file_set: xml_header_file = a_filename
		end

	set_xml_footer_file (a_filename: like xml_footer_file) is
			-- Set `xml_footer_file' to `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
		do
			xml_footer_file := a_filename
		ensure
			xml_footer_file_set: xml_footer_file = a_filename
		end

invariant

	output_directory_not_void: output_directory /= Void
	ignored_indexing_tags_not_void: ignored_indexing_tags /= Void
	feature_clause_order_not_void: feature_clause_order /= Void
	ignored_inherit_classes_not_void: ignored_inherit_classes /= Void
	ignored_feature_clauses_not_void: ignored_feature_clauses /= Void
	ignored_clusters_not_void: ignored_clusters /= Void
	mounted_libraries_not_void: mounted_libraries /= Void

end
