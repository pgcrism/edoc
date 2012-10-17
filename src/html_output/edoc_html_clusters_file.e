indexing

	description:

		"Generate an HTML File for a list of all clusters in the context."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_HTML_CLUSTERS_FILE

inherit

	EDOC_HTML_OUTPUT_FILE

create

	make

feature -- File creation

	generate is
			-- Generate overview file.
		local
			cursor: DS_LIST_CURSOR [ET_CLUSTER]
			a_character: CHARACTER
		do
			open_write
			
			print_html_head ("Clusters", html_context.relative_css_link)

			start_tag ("body")
			
				print_header_start
				print_buttons
				print_header_end

				tag_content ("h1", "Clusters")
				
				tag ("hr")
				
				start_tag_css ("ul", css_cluster_tree)
				cursor := Context.universe.clusters.clusters.new_cursor
				from
					cursor.start
				until
					cursor.after
				loop
					if Context.documented_clusters.has (cursor.item) then
						start_tag ("li")
							tag_content ("h3", print_cluster_name_to_string (cursor.item))
						end_tag
						print_subclusters_tree (cursor.item)
					end
					cursor.forth
				end
				end_tag
				
				print_footer_start
				print_buttons
				print_footer_end
			
			end_tag
			end_tag
			
			close
		end

end
