note
	description: "[
			This class is to represent a media type
			
			the Internet Media Type [9] of the attached entity if the type
			was provided via a "Content-type" field in the wgi_request header,
			or if the server can determine it in the absence of a supplied
			"Content-type" field. The syntax is the same as for the HTTP
			"Content-Type" header field.
			
			 CONTENT_TYPE = "" | media-type
			 media-type   = type "/" subtype *( ";" parameter)
			 type         = token
			 subtype      = token
			 parameter    = attribute "=" value
			 attribute    = token
			 value        = token | quoted-string
			
			The type, subtype, and parameter attribute names are not
			case-sensitive. Parameter values MAY be case sensitive. Media
			types and their use in HTTP are described in section 3.7 of
			the HTTP/1.1 specification [8].
			
			Example:
			
			 	application/x-www-form-urlencoded
				application/x-www-form-urlencoded; charset=UTF8

		]"
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_MEDIA_TYPE

inherit
	DEBUG_OUTPUT

create
	make,
	make_from_string

convert
	make_from_string ({READABLE_STRING_8, STRING_8, IMMUTABLE_STRING_8}),
	string: {READABLE_STRING_8}

feature {NONE} -- Initialization

	make (a_type, a_subtype: READABLE_STRING_8)
			-- Create Current based on `a_type/a_subtype'
		require
			not a_type.is_empty
			not a_subtype.is_empty
		do
			type := a_type
			subtype := a_subtype
		ensure
			has_no_error: not has_error
		end

	make_from_string (s: READABLE_STRING_8)
			-- Create Current from `s'
			-- if `s' does not respect the expected syntax, has_error is True
		local
			t: STRING_8
			i,n: INTEGER
			p: INTEGER
		do
				-- Ignore starting space (should not be any)
			from
				i := 1
				n := s.count
			until
				i > n or not s[i].is_space
			loop
				i := i + 1
			end
			if i < n then
					-- Look for semi colon as parameter separation
				p := s.index_of (';', i)
				if p > 0 then
					t := s.substring (i, p - 1)
					i := p + 1
					p := s.index_of (';', i)
					if p = 0 then
						add_parameter_from_string (s, i, n)
						i := n
					else
						add_parameter_from_string (s, i, p - 1)
						i := p + 1
					end
				else
					t := s.substring (i, n)
				end
					-- Remove eventual trailing space
				t.right_adjust

					-- Extract type and subtype
				p := t.index_of ('/', 1)
				if p = 0 then
					has_error := True
					type := t
					subtype := ""
				else
					subtype := t.substring (p + 1, t.count)
					type := t
					t.keep_head (p - 1)
				end
			else
				has_error := True
				type := ""
				subtype := type
			end
		ensure
			not has_error implies (create {HTTP_CONTENT_TYPE}.make_from_string (string)).same_string (string)
		end

feature -- Access

	has_error: BOOLEAN
			-- Current has error?
			--| Mainly in relation with `make_from_string'

	type: READABLE_STRING_8
			-- Main type

	subtype: READABLE_STRING_8
			-- Sub type

	has_parameter (a_name: READABLE_STRING_8): BOOLEAN
			-- Has Current a parameter?
		do
			if attached parameters as plst then
				Result := plst.has (a_name)
			end
		end

	parameter (a_name: READABLE_STRING_8): detachable READABLE_STRING_8
			-- Value for eventual parameter named `a_name'.
		do
			if attached parameters as plst then
				Result := plst.item (a_name)
			end
		end

	parameters: detachable HASH_TABLE [READABLE_STRING_8, READABLE_STRING_8]

feature -- Conversion

	string: READABLE_STRING_8
			-- String representation of type/subtype; attribute=value
		local
			res: like internal_string
		do
			res := internal_string
			if res = Void then
				create res.make_from_string (simple_type)
				if attached parameters as plst then
					across
						plst as p
					loop
						res.append_character (';')
						res.append_character (' ')
						res.append (p.key)
						res.append_character ('=')
						res.append_character ('%"')
						res.append (p.item)
						res.append_character ('%"')
					end
				end
				internal_string := res
			end
			Result := res
		end

	simple_type: READABLE_STRING_8
			-- String representation of type/subtype	
		local
			res: like internal_simple_type
			s: like subtype
		do
			res := internal_simple_type
			if res = Void then
				create res.make_from_string (type)
				s := subtype
				if not s.is_empty then
					check has_error: has_error end
						-- Just in case not is_valid, we keep in `type' the original string
					res.append_character ('/')
					res.append (s)
				end
				internal_simple_type := res
			end
			Result := res
		end

feature {NONE} -- Internal

	internal_string: detachable STRING_8

	internal_simple_type: detachable STRING_8

feature -- Status report

	same_as (other: HTTP_CONTENT_TYPE): BOOLEAN
		local
			plst,oplst: like parameters
		do
			Result := other.type.same_string (other.type) and then
						other.subtype.same_string (other.subtype)
			if Result then
				plst := parameters
				oplst := other.parameters
				if plst = oplst then
				elseif plst = Void then
					Result := False -- since oplst /= Void
				elseif oplst /= Void and then plst.count = oplst.count then
					across
						plst as p
					until
						not Result
					loop
						Result := attached oplst.item (p.key) as op_value and then p.item.same_string (op_value)
					end
				else
					Result := False
				end
			end
		end

	same_media_type (s: READABLE_STRING_8): BOOLEAN
		do
			Result := simple_type.same_string (s)
		end

	same_string (s: READABLE_STRING_8): BOOLEAN
		do
			Result := string.same_string (s)
		end

feature -- Element change

	add_parameter (a_name: READABLE_STRING_8; a_value: READABLE_STRING_8)
			-- Set parameter for `a_name' to `a_value'
		local
			plst: like parameters
		do
			plst := parameters
			if plst = Void then
				create plst.make (1)
				parameters := plst
			end
			plst.force (a_value, a_name)
			internal_string := Void
		end

	remove_parameter (a_name: READABLE_STRING_8)
			-- Remove parameter
		do
			if attached parameters as plst then
				plst.prune (a_name)
				if plst.is_empty then
					parameters := Void
				end
			end
			internal_string := Void
		end

feature {NONE} -- Implementation

	add_parameter_from_string (s: READABLE_STRING_8; start_index, end_index: INTEGER)
		local
			pn,pv: STRING_8
			i: INTEGER
			p: INTEGER
			err: BOOLEAN
		do
			-- Skip spaces
			from
				i := start_index
			until
				i > end_index or not s[i].is_space
			loop
				i := i + 1
			end
			if i < end_index then
				p := s.index_of ('=', i)
				if p > 0 and p < end_index then
					pn := s.substring (i, p - 1)
					pv := s.substring (p + 1, end_index)
					pv.right_adjust
					if pv.count > 0 and pv [1] = '%"' then
						if pv [pv.count] = '%"' then
							pv := pv.substring (2, pv.count - 1)
						else
							err := True
							-- missing closing double quote.
						end
					end
					if not err then
						add_parameter (pn, pv)
					end
				else
					-- expecting: attribute "=" value
					err := True
				end
			end
			has_error := has_error or err
		end

feature -- Status report

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			if type /= Void and subtype /= Void then
				Result := type + "/" + subtype
				if attached parameters as plst then
					across
						plst as p
					loop
						Result.append ("; " + p.key + "=" + "%"" + p.item + "%"")
					end
				end
			else
				Result := ""
			end
		end

invariant
	type_and_subtype_not_empty: not has_error implies not type.is_empty and not subtype.is_empty

note
	copyright: "2011-2012, Jocelyn Fiat, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
