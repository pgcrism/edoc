note
	description: "Summary description for {EDOC_UNIVERSE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EDOC_UNIVERSE

inherit
	ET_SYSTEM

create

	make

feature -- Access

	classes: DS_HASH_TABLE [ET_CLASS, ET_CLASS_NAME]
			-- Classes in universe
			do
				create Result.make (10)
				master_classes_do_recursive (agent (cl : ET_MASTER_CLASS; coll : DS_HASH_TABLE[ET_CLASS, ET_CLASS_NAME])
					do
						coll.force (cl.actual_class, cl.actual_class.name)
					end (?, Result))
			end

	classes_by_group (a_group: ET_GROUP): DS_ARRAYED_LIST [ET_CLASS] is
			-- Classes in universe which are in `a_group';
			-- Create a new list at each call
		require
			a_group_not_void: a_group /= Void
--		local
--			a_cursor: DS_HASH_TABLE_CURSOR [ET_CLASS, ET_CLASS_NAME]
--			a_class: ET_CLASS
		do
			Result := classes_in_group_recursive (a_group)
--			create Result.make (initial_classes_by_group_capacity)
--			a_cursor := classes.new_cursor
--			from a_cursor.start until a_cursor.after loop
--				from
--					a_class := a_cursor.item
--				until
--					a_class = Void
--				loop
--					if a_class.group = a_group then
--						Result.force_last (a_class)
--					end
--					a_class := a_class.overridden_class
--				end
--				a_cursor.forth
--			end
		ensure
			classes_not_void: Result /= Void
			no_void_class: not Result.has (Void)
		end

	eiffel_class (a_name: ET_CLASS_NAME): ET_CLASS
		require
			a_name_not_void: a_name /= Void
		do
			--	eiffel_class (a_name: ET_CLASS_NAME): ET_CLASS is
			--			-- Class named `a_name' in universe;
			--			-- add this class to universe if not found
			--		require
			--			a_name_not_void: a_name /= Void
			--		do
			--			classes.search (a_name)
			--			if classes.found then
			--				Result := classes.found_item
			--			else
			--				basic_classes.search (a_name)
			--				if basic_classes.found then
			--					Result := basic_classes.found_item
			--				else
			--					Result := ast_factory.new_class (a_name, classes.count + 1)
			--					classes.force_last (Result, a_name)
			--				end
			--			end
			--		ensure
			--			eiffel_class_not_void: Result /= Void
			--		end		
		end


end
