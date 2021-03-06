// Generated by CoffeeScript 1.12.1
(function() {
  var $, $async, $split, CND, D, FS, O, PATH, STREAM, badge, debug, echo, format_float, format_integer, help, info, mkdirp, new_numeral, rpr, through2, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'BASIC-STREAM-BENCHMARKS-2/COPY-LINES-WITH-PIPEDREAMS';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  PATH = require('path');

  FS = require('fs');

  new_numeral = require('numeral');

  format_float = function(x) {
    return (new_numeral(x)).format('0,0.000');
  };

  format_integer = function(x) {
    return (new_numeral(x)).format('0,0');
  };

  O = require('./options');

  D = require('pipedreams');

  $ = D.$, $async = D.$async;

  through2 = require('through2');

  $split = require('binary-split');

  mkdirp = require('mkdirp');

  STREAM = require('readable-stream');

  this.main = function(handler) {
    var $count, $filter_comments, $filter_empty, $pass, $select_fields, $split_fields, $trim, i, idx, input_stream, item_count, output_stream, ref, s, t0, t1;
    if (O.pass_through_asynchronous) {
      $pass = function() {
        return $async(function(data, send, end) {
          if (data != null) {
            setImmediate(function() {
              return send.done(data);
            });
          }
          if (end != null) {
            return end();
          }
        });
      };
    } else {
      $pass = D.$pass.bind(D);
    }
    $count = function() {
      return $(function(data) {
        return item_count += +1;
      });
    };
    $trim = function() {
      return $(function(line, send) {
        return send(line.trim());
      });
    };
    $filter_empty = function() {
      return $(function(line, send) {
        if (line.length !== 0) {
          return send(line);
        }
      });
    };
    $filter_comments = function() {
      return $(function(line, send) {
        if (!line.startsWith('#')) {
          return send(line);
        }
      });
    };
    $split_fields = function() {
      return $(function(line, send) {
        return send(line.split('\t'));
      });
    };
    $select_fields = function() {
      return $(function(fields, send) {
        var _, formula, glyph;
        _ = fields[0], glyph = fields[1], formula = fields[2];
        return send([glyph, formula]);
      });
    };
    mkdirp.sync(PATH.dirname(O.outputs.pipedreams));
    input_stream = FS.createReadStream(O.inputs.ids);
    output_stream = FS.createWriteStream(O.outputs.pipedreams);
    t0 = null;
    t1 = null;
    item_count = 0;
    input_stream.on('open', function() {
      return t0 = Date.now();
    });
    output_stream.on('close', function() {
      var dts, dts_txt, ips, ips_txt, item_count_txt;
      t1 = Date.now();
      dts = (t1 - t0) / 1000;
      dts_txt = format_float(dts);
      item_count_txt = format_integer(item_count);
      ips = item_count / dts;
      ips_txt = format_float(ips);
      help(PATH.basename(__filename));
      help("pass-through count: " + O.pass_through_count);
      help(item_count_txt + " items; dts: " + dts_txt + ", ips: " + ips_txt);
      return handler();
    });
    s = input_stream;
    s = s.pipe(D.$split());
    s = s.pipe($count());
    s = s.pipe($trim());
    s = s.pipe($filter_empty());
    s = s.pipe($filter_comments());
    s = s.pipe($split_fields());
    s = s.pipe($select_fields());
    s = s.pipe(D.$as_line());
    for (idx = i = 1, ref = O.pass_through_count; i <= ref; idx = i += +1) {
      s = s.pipe($pass());
    }
    return s = s.pipe(output_stream);
  };

}).call(this);

//# sourceMappingURL=copy-lines-with-pipedreams.js.map
