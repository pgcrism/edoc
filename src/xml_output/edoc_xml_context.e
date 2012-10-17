indexing
	description:

		"XML specific context information"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_CONTEXT

inherit

	EDOC_SHARED_ACCESS

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	KL_IMPORTED_CHARACTER_ROUTINES

feature -- Constants

	edoc_namespace: STRING is "edoc"

feature -- Header buttons

	overview_page_link: STRING
			-- Link to overview page

	cluster_page_link: STRING
			-- Link to cluster page

	class_page_link: STRING
			-- Link to class page

	usage_page_link: STRING
			-- Link to usage page

	classes_page_link: STRING
			-- Link to classes page

	clusters_page_link: STRING
			-- Link to clusters page

	index_page_link: STRING
			-- Link to index page

	Active_page_link: STRING is "ACTIVE_LINK"
			-- Link denoting active link

	setup_overview_page_links is
			-- Setup button links for overview page.
		do
			overview_page_link := Active_page_link
			cluster_page_link := Void
			class_page_link := Void
			usage_page_link := Void
			classes_page_link := relative_classes_link
			clusters_page_link := relative_clusters_link
			index_page_link := relative_index_link ('a')
		end

	setup_cluster_page_links (a_cluster: ET_CLUSTER) is
			-- Setup button links for cluster page of `a_cluster'.
		do
			overview_page_link := relative_overview_link
			cluster_page_link := Active_page_link
			class_page_link := Void
			usage_page_link := Void
			classes_page_link := relative_classes_link
			clusters_page_link := relative_clusters_link
			index_page_link := relative_index_link (a_cluster.name.item (1))
		end

	setup_class_page_links (a_class: ET_CLASS) is
			-- Setup button links for class page of `a_class'.
		do
			overview_page_link := relative_overview_link
			cluster_page_link := cluster_link_by_cluster (a_class.group.cluster)
			class_page_link := Active_page_link
			usage_page_link := usage_link_by_class (a_class)
			classes_page_link := relative_classes_link
			clusters_page_link := relative_clusters_link
			index_page_link := relative_index_link (a_class.name.name.item (1))
		end

	setup_usage_page_links (a_class: ET_CLASS) is
			-- Setup button links for usage page of `a_class'.
		do
			overview_page_link := relative_overview_link
			cluster_page_link := cluster_link_by_cluster (a_class.group.cluster)
			class_page_link := class_link_by_class (a_class)
			usage_page_link := Active_page_link
			classes_page_link := relative_classes_link
			clusters_page_link := relative_clusters_link
			index_page_link := relative_index_link (a_class.name.name.item (1))
		end

	setup_classes_page_links is
			-- Setup button links for classes page.
		do
			overview_page_link := relative_overview_link
			cluster_page_link := Void
			class_page_link := Void
			usage_page_link := Void
			classes_page_link := Active_page_link
			clusters_page_link := relative_clusters_link
			index_page_link := relative_index_link ('a')
		end

	setup_clusters_page_links is
			-- Setup button links for clusters page.
		do
			overview_page_link := relative_overview_link
			cluster_page_link := Void
			class_page_link := Void
			usage_page_link := Void
			classes_page_link := relative_classes_link
			clusters_page_link := Active_page_link
			index_page_link := relative_index_link ('a')
		end

	setup_index_page_links is
			-- Setup button links for index page.
		do
			overview_page_link := relative_overview_link
			cluster_page_link := Void
			class_page_link := Void
			usage_page_link := Void
			classes_page_link := relative_classes_link
			clusters_page_link := relative_clusters_link
			index_page_link := Active_page_link
		end

feature -- Filenames

	xsd_file_name: STRING is "edoc.xsd"
			-- Filename of xsd file

	cluster_file_name (a_cluster: ET_CLUSTER): STRING is
			-- Filename of `a_cluster'
		require
			a_cluster_not_void: a_cluster /= Void
		do
			Result := "cluster."+a_cluster.prefixed_name.as_lower+".xml"
		ensure
			cluster_file_name_not_void: Result /= Void
		end

	class_file_name (a_class: ET_CLASS): STRING is
			-- Filename of `a_class'
		require
			a_class_not_void: a_class /= Void
		do
			Result := a_class.name.name.as_lower+".xml"
		ensure
			class_file_name_not_void: Result /= Void
		end

	usage_file_name (a_class: ET_CLASS): STRING is
			-- Filename of usage file of `a_class'
		require
			a_class_not_void: a_class /= Void
		do
			Result := "usage."+a_class.name.name.as_lower+".xml"
		ensure
			usage_file_name_not_void: Result /= Void
		end

	overview_file_name: STRING is "index.xml"
			-- Filename of overview

	classes_file_name: STRING is "classes.all.xml"
			-- Filename of classes file

	clusters_file_name: STRING is "clusters.all.xml"
			-- Filename of classes file

	index_file_name (a_character: CHARACTER): STRING is
			-- Filename of index file of `a_character'
		require
			a_character_valid: a_character.is_upper or a_character.is_lower
		do
			Result := "index-"+CHARACTER_.as_lower (a_character).out+".xml"
		ensure
			index_file_name_not_void: Result /= Void
		end

	index_all_file_name: STRING is
			-- Filename of index file over all items
		do
			Result := "index-all.xml"
		ensure
			index_all_filename_not_void: Result /= Void
		end


feature -- Links

	cluster_link_by_cluster (a_cluster: ET_CLUSTER): STRING is
			-- Generate link to `a_cluster'.
		require
			a_cluster_not_vod: a_cluster /= Void
		do
			if Context.documented_clusters.has (a_cluster) then
				Result := Context.relative_cluster_directory (a_cluster)
				if Result.is_empty then
					Result := cluster_file_name (a_cluster)
				else
					Result.append_string ("/"+cluster_file_name (a_cluster))
				end
			end
		ensure
			link_to_included_cluster_not_void: Context.documented_clusters.has (a_cluster) implies Result /= Void
		end

	class_link_by_class (a_class: ET_CLASS): STRING is
			-- Generate link to `a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			if Context.documented_classes.has (a_class) then
				Result := Context.relative_cluster_directory (a_class.group.cluster)
				if Result.is_empty then
					Result := class_file_name (a_class)
				else
					Result.append_string ("/"+class_file_name (a_class))
				end
			end
		ensure
			link_to_included_class_not_void: Context.documented_classes.has (a_class) implies Result /= Void
		end

	class_link_by_name (a_class_name: ET_CLASS_NAME): STRING is
			-- Generate link to `a_class_name'.
			-- Return `Void' if `a_class_name' is not part of `universe'.
		require
			a_class_name_not_void: a_class_name /= Void
		local
			a_class: ET_CLASS
		do
			a_class := Context.universe.class_by_name (a_class_name.name)
			if a_class = Void or else a_class.group = Void then
				Result := Void
			else
				Result := class_link_by_class (a_class)
			end
		ensure
			link_to_included_class_not_void: Context.universe.has_class (a_class_name) and then Context.documented_classes.has (Context.universe.class_by_name (a_class_name.name)) implies Result /= Void
		end

	usage_link_by_class (a_class: ET_CLASS): STRING is
			-- Generate link to usage page of `a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			if Context.documented_classes.has (a_class) then
				Result := Context.relative_cluster_directory (a_class.group.cluster)+"/"+usage_file_name (a_class)
			end
		ensure
			link_to_included_class_not_void: Context.documented_classes.has (a_class) implies Result /= Void
		end

	creator_anchor_by_feature (a_feature: ET_FEATURE): STRING is
			-- Generate anchor to `a_feature' as a creator.
		require
			a_featuren_not_void: a_feature /= Void
		do
			Result := "creator-"+xhtml_compatible_anchor (a_feature.name.name.as_lower)
		ensure
			anchor_not_void: Result /= Void
		end

	creator_link_by_feature (a_feature: ET_FEATURE; a_class: ET_CLASS): STRING is
			-- Generate link to `a_feature' in `a_class' as creator.
			-- If `a_class' is Void create a relative link
		require
			a_feature_not_void: a_feature /= Void
		local
			class_link: STRING
		do
			if a_class = Void then
				Result := "#"+creator_anchor_by_feature (a_feature)
			else
				class_link := class_link_by_class (a_class)
				if class_link /= Void then
					Result := class_link+"#"+creator_anchor_by_feature (a_feature)
				end
			end
		ensure
			relative_link_not_void: a_class = Void implies Result /= Void
		end

	feature_anchor_by_feature (a_feature: ET_FEATURE): STRING is
			-- Generate anchor to `a_feature'.
		require
			a_featuren_not_void: a_feature /= Void
		do
			Result := xhtml_compatible_anchor (a_feature.name.name.as_lower)
		ensure
			anchor_not_void: Result /= Void
		end

	feature_link_by_feature (a_feature: ET_FEATURE; a_class: ET_CLASS): STRING is
			-- Generate link to `a_feature' in `a_class'.
			-- If `a_class' is Void create a relative link
		require
			a_feature_not_void: a_feature /= Void
		local
			class_link: STRING
		do
			if a_class = Void then
				Result := "#"+feature_anchor_by_feature (a_feature)
			else
				class_link := class_link_by_class (a_class)
				if class_link /= Void then
					Result := class_link+"#"+feature_anchor_by_feature (a_feature)
				end
			end
		ensure
			relative_link_not_void: a_class = Void implies Result /= Void
		end

	relative_overview_link: STRING is
			-- Link to overview page
		do
			Result := Context.relative_output_directory+overview_file_name
		ensure
			relative_overview_link_not_void: Result /= Void
		end

	relative_index_link (a_character: CHARACTER): STRING is
			-- Link to index page of `a_character'
		require
			a_character_valid: a_character.is_upper or a_character.is_lower
		do
			Result := Context.relative_output_directory+index_file_name (a_character)
		ensure
			relative_index_link_not_void: Result /= Void
		end

	relative_index_all_link: STRING is
			-- Link to index-all page
		do
			Result := Context.relative_output_directory+index_all_file_name
		ensure
			relative_index_all_link_not_void: Result /= Void
		end

	relative_classes_link: STRING is
			-- Link to classes page
		do
			Result := Context.relative_output_directory+classes_file_name
		ensure
			relative_classes_link_not_void: Result /= Void
		end

	relative_clusters_link: STRING is
			-- Link to clusters page
		do
			Result := Context.relative_output_directory+clusters_file_name
		ensure
			relative_clusters_link_not_void: Result /= Void
		end

	relative_xsd_link: STRING is
			-- Link to xsd-document
		do
			Result := context.relative_output_directory + xsd_file_name
		ensure
			relative_xsd_link_not_void: Result /= Void
		end

feature -- Support

	xhtml_escaped_string (a_string: STRING): STRING is
			-- XHTML conform string without spaces
		require
			a_string_not_void: a_string /= Void
		do
			-- TODO: smartly replace amersand
--			Result := STRING_.replaced_all_substrings (Result, "&", "&amp;")
--			Result := STRING_.replaced_all_substrings (a_string, " ", "&nbsp;")
--			Result := STRING_.replaced_all_substrings (Result, "%"", "&quot;")
			Result := STRING_.replaced_all_substrings (a_string, "<", "&lt;")
			Result := STRING_.replaced_all_substrings (Result, ">", "&gt;")
		ensure
			result_not_void: Result /= Void
		end

	xhtml_compatible_anchor (a_string: STRING): STRING is
			-- XHTML conform anchor for 'a_string'
		require
			a_string_not_void: a_string /= Void
		do
			Result := STRING_.replaced_all_substrings (a_string, " ", "_")
			Result := STRING_.replaced_all_substrings (Result, "%"", "_quot_")
			Result := STRING_.replaced_all_substrings (Result, "<", "_lt_")
			Result := STRING_.replaced_all_substrings (Result, ">", "_gt_")
			Result := STRING_.replaced_all_substrings (Result, "@", "_at_")
			Result := STRING_.replaced_all_substrings (Result, "+", "_plus_")
			Result := STRING_.replaced_all_substrings (Result, "-", "_minus_")
			Result := STRING_.replaced_all_substrings (Result, "/", "_slash_")
			Result := STRING_.replaced_all_substrings (Result, "\", "_backslash_")
			Result := STRING_.replaced_all_substrings (Result, "=", "_equal_")
			Result := STRING_.replaced_all_substrings (Result, "*", "_asterix_")
			Result := STRING_.replaced_all_substrings (Result, "|", "_pipe_")
			Result := STRING_.replaced_all_substrings (Result, "^", "_caret_")
			Result := STRING_.replaced_all_substrings (Result, "&", "_amp_")
			Result := STRING_.replaced_all_substrings (Result, "#", "_grid_")
		ensure
			result_not_void: Result /= Void
		end

end
