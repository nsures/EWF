note
	description: "Summary description for {CMS_DEFAULT_SETUP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_DEFAULT_SETUP

inherit
	CMS_SETUP
		redefine
			default_create
		end

create
	default_create,
	make,
	make_from_file

feature {NONE} -- Initialization

	make (a_cfg: CMS_CONFIGURATION)
		do
			configuration := a_cfg
			default_create
		end

	make_from_file (fn: READABLE_STRING_8)
		local
			cfg: CMS_CONFIGURATION
		do
			create cfg.make_from_file (fn)
			make (cfg)
		end

	default_create
		do
			Precursor
			build_modules
			build_storage
			build_session_manager
			build_auth_engine
			build_mailer
		end

feature -- Access

	modules: ARRAYED_LIST [CMS_MODULE]

	storage: CMS_STORAGE
			-- CMS persistent layer

	session_manager: WSF_SESSION_MANAGER
			-- CMS Session manager

	auth_engine: CMS_AUTH_ENGINE
			-- CMS Authentication engine

	mailer: CMS_MAILER

feature {NONE} -- Initialization		

	build_modules
		local
			m: CMS_MODULE
		do
			create modules.make (3)

			-- Core
			create {USER_MODULE} m.make
			m.enable
			modules.extend (m)

			create {ADMIN_MODULE} m.make
			m.enable
			modules.extend (m)

			create {NODE_MODULE} m.make
			m.enable
			modules.extend (m)
		end

	build_storage
		local
			dn: DIRECTORY_NAME
		do
			if attached configuration as cfg and then attached cfg.var_location as l_site_var_dir then
				create dn.make_from_string (l_site_var_dir)
			else
				create dn.make
			end
			dn.extend ("_storage_")
			create {CMS_SED_STORAGE} storage.make (dn.string)
		end

	build_session_manager
		local
			dn: DIRECTORY_NAME
		do
			if attached configuration as cfg and then attached cfg.var_location as l_site_var_dir then
				create dn.make_from_string (l_site_var_dir)
			else
				create dn.make
			end
			dn.extend ("_storage_")
			dn.extend ("_sessions_")
			create {WSF_FS_SESSION_MANAGER} session_manager.make_with_folder (dn.string)
		end

	build_auth_engine
		do
			create {CMS_STORAGE_AUTH_ENGINE} auth_engine.make (storage)
		end

	build_mailer
		local
			ch_mailer: CMS_CHAIN_MAILER
			st_mailer: CMS_STORAGE_MAILER
		do
			create st_mailer.make (storage)
			create ch_mailer.make (st_mailer)
			ch_mailer.set_next (create {CMS_SENDMAIL_MAILER})
			mailer := ch_mailer
		end

feature -- Change

	add_module (m: CMS_MODULE)
		do
			modules.force (m)
		end

end
