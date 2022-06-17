fx_version 'bodacious'
games { 'gta5' }

author 'Anderson Fabris'
description 'Script inicial projeto - phone'
version '2.0'
acesso 'https://discord.evolutionfivem.com'

ui_page "html/index.html"

shared_scripts {
    "config.lua",
    "locale.lua",
    "locales/*.lua",
}

client_scripts {
	"@vrp/lib/utils.lua",
	'locale.lua',
	'locales/*.lua',
    'client/*.lua',
}

server_scripts {
	"@vrp/lib/utils.lua",
	'locale.lua',
	'locales/*.lua',
	"system/functions.lua",
    'server/*.lua',
}

files {
    'html/*',
    'html/**/*',
    'html/**/**/*',
}

dependencies {
    'vrp',
   -- 'oxmysql'
}