note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	CMS_FORM_FIELD_SET

inherit
	CMS_FORM_ITEM

	ITERABLE [CMS_FORM_ITEM]

	WITH_CSS_ID

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			create items.make (0)
		end

feature -- Access

	legend: detachable READABLE_STRING_8

	is_collapsible: BOOLEAN

feature -- Access

	new_cursor: ITERATION_CURSOR [CMS_FORM_ITEM]
			-- Fresh cursor associated with current structure
		do
			Result := items.new_cursor
		end

feature -- Change

	set_legend (v: like legend)
		do
			legend := v
		end

	extend (i: CMS_FORM_ITEM)
		do
			items.force (i)
		end

	prepend (i: CMS_FORM_ITEM)
		do
			items.put_front (i)
		end

	extend_text (t: READABLE_STRING_8)
		do
			items.force (create {CMS_FORM_RAW_TEXT}.make (t))
		end

	set_collapsible (b: BOOLEAN)
		do
			is_collapsible := b
			if b then
				add_css_class ("collapsible")
			else
				remove_css_class ("collapsible")
			end
		end

	set_collapsed (b: BOOLEAN)
		do
			if b then
				add_css_class ("collapsed")
			else
				remove_css_class ("collapsed")
			end
		end

feature -- Conversion

	append_to_html (a_theme: CMS_THEME; a_html: STRING_8)
		do
			a_html.append ("<fieldset")
			append_css_class_to (a_html, Void)
			append_css_id_to (a_html)
			append_css_style_to (a_html)

			a_html.append (">%N")
			if attached legend as leg then
				a_html.append ("<legend>" + leg + "</legend>%N")
			end
			across
				items as c
			loop
				c.item.append_to_html (a_theme, a_html)
			end
			a_html.append ("%N</fieldset>%N")
		end

feature {NONE} -- Implementation

	items: ARRAYED_LIST [CMS_FORM_ITEM]

end
