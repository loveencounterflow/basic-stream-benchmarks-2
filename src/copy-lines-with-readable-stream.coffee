

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'BASIC-STREAM-BENCHMARKS-2/COPY-LINES-WITH-READABLE-STREAM'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
PATH                      = require 'path'
FS                        = require 'fs'
# OS                        = require 'os'
#...........................................................................................................
new_numeral               = require 'numeral'
format_float              = ( x ) -> ( new_numeral x ).format '0,0.000'
format_integer            = ( x ) -> ( new_numeral x ).format '0,0'
#...........................................................................................................
O                         = require './options'
through2                  = require 'through2'
$split                    = require 'binary-split'
mkdirp                    = require 'mkdirp'
STREAM                    = require 'readable-stream'


#-----------------------------------------------------------------------------------------------------------
$show = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( chunk, _, done ) ->
    @push chunk
    # debug '11021', chunk.length
    debug '11021', chunk
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$pass = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( chunk, _, done ) ->
    @push chunk
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$count = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( chunk, _, done ) ->
    @push chunk
    item_count += +1
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$decode = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( chunk, _, done ) ->
    @push chunk.toString()
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$trim = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( line, _, done ) ->
    @push line.trim()
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$filter_empty = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( line, _, done ) ->
    @push line unless line.length is 0
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$filter_comments = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( line, _, done ) ->
    @push line unless line.startsWith '#'
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$split_fields = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( line, _, done ) ->
    @push line.split '\t'
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$select_fields = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( fields, _, done ) ->
    [ _, glyph, formula, ] = fields
    @push [ glyph, formula, ]
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$as_text = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( fields, _, done ) ->
    @push JSON.stringify fields
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
$as_line = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( text, _, done ) ->
    @push text + '\n'
    done()
  return R

#-----------------------------------------------------------------------------------------------------------
mkdirp.sync PATH.dirname O.outputs.readablestream
input_stream              = FS.createReadStream   O.inputs.ids
output_stream             = FS.createWriteStream  O.outputs.readablestream

#-----------------------------------------------------------------------------------------------------------
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
s = input_stream
s = s.pipe $split()
s = s.pipe $decode()
s = s.pipe $count()
s = s.pipe $trim()
s = s.pipe $filter_empty()
s = s.pipe $filter_comments()
s = s.pipe $split_fields()
s = s.pipe $select_fields()
s = s.pipe $as_text()
s = s.pipe $as_line()
s = s.pipe $pass() for idx in [ 1 .. 100 ]
s = s.pipe output_stream










