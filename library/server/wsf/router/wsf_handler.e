note
	description: "Summary description for {WSF_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	WSF_HANDLER

feature -- Status report

	is_valid_context (req: WSF_REQUEST): BOOLEAN
			-- Is `req' valid context for current handler?
		do
			Result := True
		end

feature {WSF_ROUTER} -- Mapping

	on_mapped (a_mapping: WSF_ROUTER_MAPPING; a_rqst_methods: detachable WSF_REQUEST_METHODS)
			-- Callback called when a router map a route to Current handler
		do
		end

note
	copyright: "2011-2012, Jocelyn Fiat, Javier Velilla, Olivier Ligot, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
