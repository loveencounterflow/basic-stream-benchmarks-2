

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'BASIC-STREAM-BENCHMARKS-2/COPY-LINES-WITH-PULL-STREAM'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
new_numeral               = require 'numeral'
format_float              = ( x ) -> ( new_numeral x ).format '0,0.000'
format_integer            = ( x ) -> ( new_numeral x ).format '0,0'
#...........................................................................................................
PATH                      = require 'path'
FS                        = require 'fs'
mkdirp                    = require 'mkdirp'
#...........................................................................................................
O                         = require './options'
$split                    = require 'pull-split'
$stringify                = require 'pull-stringify'
$utf8                     = require 'pull-utf8-decoder'
pull                      = require 'pull-stream'
through                   = require 'pull-through'
STPS                      = require 'stream-to-pull-stream'


#-----------------------------------------------------------------------------------------------------------
mkdirp.sync PATH.dirname O.outputs.pullstream
input_stream              = FS.createReadStream   O.inputs.ids
output_stream             = FS.createWriteStream  O.outputs.pullstream

#-----------------------------------------------------------------------------------------------------------
pipeline                  = []
push                      = pipeline.push.bind pipeline
t0                        = null
t1                        = null
item_count                = 0

#-----------------------------------------------------------------------------------------------------------
input_stream.on 'open', ->
  t0 = Date.now()
  help "input_stream: open"

#-----------------------------------------------------------------------------------------------------------
output_stream.on 'close', ->
  t1              = Date.now()
  dts             = ( t1 - t0 ) / 1000
  dts_txt         = format_float dts
  item_count_txt  = format_integer item_count
  ips             = item_count / dts
  ips_txt         = format_float ips
  help "output_stream: close"
  help "#{item_count_txt} items; dts: #{dts_txt}, ips: #{ips_txt}"
  help 'ok'

#-----------------------------------------------------------------------------------------------------------
$input = -> STPS.source input_stream

#-----------------------------------------------------------------------------------------------------------
$output = ->
  return STPS.sink output_stream, ( error ) ->
    throw error if error?
    t1  = Date.now()
    dts = ( t1 - t0 ) / 1000

#-----------------------------------------------------------------------------------------------------------
push $input()
push $utf8()
push $split()
push pull.map      ( line    ) -> item_count += +1; return line
push pull.map      ( line    ) -> line.trim()
push pull.filter   ( line    ) -> line.length > 0
push pull.filter   ( line    ) -> not line.startsWith '#'
# push pull.filter   ( line    ) -> ( /魚/ ).test line
push pull.map      ( line    ) -> line.split '\t'
push pull.map      ( fields  ) -> [ _, glyph, formula, ] = fields; return [ glyph, formula, ]
push pull.map      ( fields  ) -> JSON.stringify fields
push pull.map      ( line    ) -> line + '\n'
push $output()


############################################################################################################
pull pipeline...

