






############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'BASIC-STREAM-BENCHMARKS/COPY-LINES'
debug                     = CND.get_logger 'debug',     badge
PATH                      = require 'path'


module.exports            = O = {}
O.inputs                  = {}
O.outputs                 = {}
O.inputs.ids              = PATH.resolve __dirname, '../test-data/ids.txt'
O.outputs.pullstream      = PATH.resolve __dirname, '../outputs/with-pull-stream.txt'
O.outputs.readablestream  = PATH.resolve __dirname, '../outputs/with-readable-stream.txt'
O.outputs.pipedreams      = PATH.resolve __dirname, '../outputs/with-pipedreams.txt'




