indexing

	description:

		"Generate an XML File for a list of all clusters in the context."

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_CLUSTERS_FILE

inherit

	EDOC_XML_OUTPUT_FILE

create

	make

feature -- File creation

	generate is
			-- Generate overview file.
		local
			cursor: DS_LIST_CURSOR [ET_CLUSTER]
		do
			open_write
			print_xml_head ("Clusters", xml_context.relative_xsd_link)

			print_header_start
			print_header_end

			tag_content ("title", "Clusters")

			start_tag ("itemizedlist")
			cursor := Context.universe.clusters.clusters.new_cursor
			from
				cursor.start
			until
				cursor.after
			loop
				if Context.documented_clusters.has (cursor.item) then
					start_tag ("listitem")
						content_line (print_cluster_name_to_string (cursor.item))
					end_tag
					print_subclusters_tree (cursor.item)
				end
				cursor.forth
			end
			end_tag -- itemized_list

			print_footer_start
			print_buttons
			print_footer_end

			print_xml_footer
			close
		end

end
