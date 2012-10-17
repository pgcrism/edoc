indexing

	description:

		"Shared css classes"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_SHARED_CSS_CONSTANTS

feature -- Common
	
	css_indent: STRING is "indent"
			--CSS class for indentation

	css_keyword: STRING is "keyword"
			-- CSS class for keywords
	
	css_special_keyword: STRING is "special-keyword"
			-- CSS class for keywords

	css_symbol: STRING is "symbol"
			-- CSS class for symbols

	css_edoc_notice: STRING is "edoc-notice"
			-- CSS class for edoc notice

feature -- Clusters

	css_cluster_name: STRING is "cluster-name"
			-- CSS class for a cluster name

	css_linked_cluster_name: STRING is "cluster-name"
			-- CSS class for a cluster name as a link

feature -- Classes

	css_class_name: STRING is "class-name"
			-- CSS class for a class name

	css_linked_class_name: STRING is "class-name"
			-- CSS class for a class name as a link

	css_class: STRING is "class"
			-- CSS class for a class

	css_inherit_list: STRING is "indent"
			-- CSS class for inherit list
	
feature -- Features

	css_feature_name: STRING is "feature-name"
			-- CSS class for a feature name
	
	css_linked_feature_name: STRING is "feature-name"
			-- CSS class for a feature name as link

	css_feature_comment_body: STRING is "indent"
	 		-- CSS class for a feature comment body
	 
	css_feature_clause_body: STRING is "indent"
			-- CSS class for a feature clause body
	
	css_feature: STRING is "feature"
			-- CSS class for a feature
	
	css_feature_body: STRING is "indent"
			-- CSS class for a feature body

	css_assertion_body: STRING is "indent"
			-- CSS class for invariant / precondition / postcondition body
	
	css_assertion_tag: STRING is "assertion-tag"
			-- CSS class for an assertion tag

feature -- Comments

	css_comment: STRING is "comment"
			-- CSS class comments

	css_commented_class_name: STRING is "class-name-comment"
			-- CSS class for a class name in a comment

	css_commented_feature_name: STRING is "feature-name-comment"
			-- CSS class for a feature name in a comment
	
	css_invariant_comment: STRING is "comment indent"
			-- CSS class for a comment in invariant clause

feature -- Indexing

	css_indexing: STRING is "indexing"
			-- CSS class for indexing clause
	
	css_indexing_list: STRING is "indexing-list indent"
			-- CSS class for indexing list
	
	css_indexing_tag: STRING is "indexing-tag"
			-- CSS class for indexing tag
	
	css_indexing_body: STRING is "indent"
			-- CSS class for indexing body
	
feature -- Page layout

	css_header: STRING is "header"
			-- CSS class for header

	css_header_title: STRING is "header-title"
			-- CSS class for header

	css_footer: STRING is "footer"
			-- CSS class for a footer

	css_footer_title: STRING is "footer-title"
			-- CSS class for a footer

	css_buttons: STRING is "buttons"
			-- CSS class for a header button

	css_active_button: STRING is "active-button"
			-- CSS class for a button

	css_button: STRING is "button"
			-- CSS class for a button

	css_cluster_name_small: STRING is "cluster-small"
			-- CSS class for cluster link (small)
	
	css_ancestors_list: STRING is "indent"
			-- CSS class for ancestors list

	css_descendants_list: STRING is "indent"
			-- CSS class for descendants list

	css_index_list: STRING is "index-list"
			-- CSS class for index list

	css_index_small: STRING is "index-small"
			-- CSS class for small index text

	 css_cluster_tree: STRING is "cluster-tree"
	 		-- CSS class for a cluster tree

feature -- Feature list

	css_feature_list: STRING is "feature-list"
			-- CSS class for feature list
	
	css_feature_list_clause: STRING is "feature-list-clauses"
			-- CSS class for feature clause in feature list
	
	css_feature_list_feature: STRING is "feature-list-features"
			-- CSS class for feature in feature list
	
end
