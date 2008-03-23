BASE = File.dirname(File.expand_path(File.dirname(__FILE__)))
  
def sudo_script( file )
  script = File.read( "#{ BASE }/#{ file }" )
  put script, '/tmp/cap_script', :mode => 0755
  script = File.read( "#{ BASE }/bin/functions.sh" )
  put script, '/tmp/functions.sh', :mode => 0755
  sudo '/tmp/cap_script; rm /tmp/cap_script; rm /tmp/functions.sh'
end

def upload( file, dest, params = {} )
  sput File.read( "#{ BASE }/#{ file }" ), dest, params
end

def sput ( data, dest, params = {} )
  put data, '/tmp/cap_upload', :mode => params[:mode]
  sudo "chown #{ params[:owner] || 'root' }:#{ params[:group] || 'root' } /tmp/cap_upload"
  sudo "mv /tmp/cap_upload #{dest}"
end

def runl( cmd )
  block ||= self.class.default_io_proc
  logger.trace "executing #{cmd.strip.inspect}" if logger
  system( *cmd ) or raise $?
  logger.trace "command finished" if logger
end

def sudol( cmd )
  block ||= self.class.default_io_proc
  to_run = ['sudo', *cmd]
  system( *to_run ) or raise $?
end

def sudol_scripts( *scripts )
  scripts.each do |script|
    sudol "#{ BASE }/bin/#{ script }.sh"
  end
end

def run_ldap( cmd )
  run cmd do |ch, stream, data|
    if data =~ /^Please enter your password:/
      ch.send_data( Capistrano::CLI.password_prompt + "\n" )
    end
  end
end

def user_ldif( user, pass, uid, gid )
  require 'base64'
  self[:last] ||= user.capitalize
  ldif = %{dn: uid=#{ user },ou=people,dc=kineticode,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: inetLocalMailRecipient
uid: #{ user }
mail: #{ user }@kineticode.com
mailLocalAddress: #{ user }@kineticode.com\n}
  [
    [ :email,  'mail' ],
    [ :email,  'mailLocalAddress'         ],
    [ :name,   'cn'                       ],
    [ :last,   'sn'                       ],
    [ :first,  'givenName'                ],
    [ :init,   'initials'                 ],
    [ :title,  'title'                    ],
    [ :work,   'telephoneNumber'          ],
    [ :home,   'homeTelephoneNumber'      ],
    [ :mobile, 'mobile'                   ],
    [ :fax,    'facsimileTelephoneNumber' ],
    [ :url,    'labeledURI'               ],
  ].each do | var, label |
    if val = self[var]
      ldif += "#{ label }: #{ val }\n"
    end
  end

  ldif += %{mailHost: mail.kineticode.com
loginShell: /bin/bash
uidNumber: #{ uid }
gidNumber: #{ gid }
homeDirectory: /home/#{ user }
gecos: #{ self[:name] }
preferredLanguage: en-us
mailRoutingAddress: #{ user }@kineticode.com
userPassword:: #{ Base64.encode64( pass )}\n}

  return ldif
end

def genpass
  chars = (33 .. 126).map { |i| i.chr }
  size  = (8..16).to_a[ rand(9) ]
  ( 1 .. size ).map { |a| chars[ rand( chars.size ) ] }.join
end