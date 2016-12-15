

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'BASIC-STREAM-BENCHMARKS-2/CLI'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
{ step, }                 = require 'coffeenode-suspend'
#...........................................................................................................
O                         = require './options'


#-----------------------------------------------------------------------------------------------------------
cli = ( require 'nash' )()

#-----------------------------------------------------------------------------------------------------------
run_copy_benchmarks = ( data, flags, done ) ->
  step ( resume ) ->
    urge "run 'copy' benchmarks"
    # whisper '33301', data
    # whisper '33301', flags
    O.pass_through_count = flags[ 'n' ] ? 0
    yield ( require './copy-lines-with-pull-stream'     ).main resume
    yield ( require './copy-lines-with-readable-stream' ).main resume
    yield ( require './copy-lines-with-pipedreams'      ).main resume
    done()

#-----------------------------------------------------------------------------------------------------------
cli
  .command 'copy'
  .handler run_copy_benchmarks

#-----------------------------------------------------------------------------------------------------------
cli
  .default()
  .handler ( data, flags, done ) ->
    command = flags[ '_' ]
    warn "unrecognized command #{rpr command}"
    done()

#-----------------------------------------------------------------------------------------------------------
cli.run process.argv, ->
  whisper "finished"
  return null


