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
