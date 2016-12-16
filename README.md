# basic-stream-beanchmarks-2

## Installation

```bash
git clone https://github.com/loveencounterflow/basic-stream-benchmarks-2.git
cd basic-stream-benchmarks-2
npm install
```

## Motivation

Being disappointed with the performance of NodeJS standard issue streams (as available in the standard
library or as a standalone module, [Readable-Stream](https://github.com/nodejs/readable-stream)), I started
to experiment to see how fast you can get with streams (especially with a view to improve performance of my
own streaming library, [PipeDreams](https://github.com/loveencounterflow/pipedreams), which is built on top
of [through2](https://github.com/rvagg/through2), which in turn is built on top of Readable-Stream).

Much to my surprise and chagrin, I soon found that one factor in the equation (not the only one, but in
longer  pipelines easily the dominant one) that determines how fast a NodeJS stream will pump data is the
**mere length of a given processing pipeline** (i.e. the number of transforms between source and sink).

In order to get a handle on exactly how severe that effect is, I devised a simple and somewhat realistic
processing task: given an MB-sized text file, split it into lines, filter empty lines and comments, split
each line on tabs, select some fields, serialize the fields with JSON, append a newline character to each
line, and write them out into another file. This series of basic steps is meant to provide a backdrop to
answer the simple question: how many lines of text can you expect to process with NodeJS streams each
second? The answer will, of course, vary according to hardware, details of the processing steps, and shape
of the input data, so I did my best to use simple implementations and an 'average' (well, for my daily work
at least) data source.

Then, I threw in a maximally simple stream transform that does nothing but pass on each line as-is, and stick
variable numbers of those pass-through transforms into the processing pipeline. Ideally, you'd want to spend
all your time doing meaningful work on the data, and see as little as possible time being spent in do-
nothing functions. **Turns out every single stream transform you add to a NodeJS streams pipeline will
worsen your throughput considerably**.

I re-implemented the above using

* [PipeDreams](https://github.com/loveencounterflow/pipedreams),
* [Readable-Stream](https://github.com/nodejs/readable-stream), and
* [Pull-Stream](https://github.com/pull-stream/pull-stream)).

The big surprise here is really Pull-Stream: with a short pipeline, it is almost twice as performant
as the Readable-Stream approach; when you stick a hundred or so no-op transforms into the pipeline,
Pull-Stream remains unaffected, but **Readable-Stream drops to below 10% of Pull-Stream's performance**,
and it gets consistently worse for Readable-Stream as you keep adding transforms.

## Methodology

```coffee

$trim = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( line, _, done ) ->
    @push line.trim()
    done()
  return R

$filter_empty = ->
  R = new STREAM.Transform objectMode: true
  R._transform = ( line, _, done ) ->
    @push line unless line.length is 0
    done()
  return R

...

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
s = s.pipe $pass() for idx in [ 1 .. O.pass_through_count ] by +1
s = s.pipe output_stream


```

## Results

| pass-through count | 0       | 100     | 200     | 300     |
| ------:            | ------: | ------: | ------: | ------: |
| **pipedreams**     | 4.38    | 21.36   | 40.21   | 59.4    |
| **pull**           | 1.2     | 1.16    | 1.14    | 1.14    |
| **readable**       | 2.08    | 15.86   | 31.7    | 44.77   |

> Time taken (in seconds) to process and write 81,885 lines of text of file `test-data/ids.txt` (1,996,103
> bytes) with 0, 100, 200, and 300 pass-through transforms in the pipeline, respectively, using three
> processing models (built on [PipeDreams](https://github.com/loveencounterflow/pipedreams),
> [Readable-Stream](https://github.com/nodejs/readable-stream), and
> [Pull-Stream](https://github.com/pull-stream/pull-stream)). **Smaller is better**.



| pass-through count | 0         | 100       | 200       | 300       |
| ------:            | ------:   | ------:   | ------:   | ------:   |
| **pipedreams**     | 18,699.48 | 3,834.29  | 2,036.64  | 1,378.54  |
| **pull**           | 68,181.52 | 70,530.58 | 71,578.67 | 71,704.03 |
| **readable**       | 39,405.68 | 5,164.62  | 2,583.45  | 1,828.97  |

> Items (lines) per second achieved when processing and writing 81,885 lines of text of file `test-
> data/ids.txt` (1,996,103 bytes) with 0, 100, 200, and 300 pass-through transforms in the pipeline,
> respectively, using three processing models (built on
> [PipeDreams](https://github.com/loveencounterflow/pipedreams),
> [Readable-Stream](https://github.com/nodejs/readable-stream), and
> [Pull-Stream](https://github.com/pull-stream/pull-stream)). **Bigger is better**.

![charts](https://raw.githubusercontent.com/loveencounterflow/basic-stream-benchmarks-2/master/charts.png)

> **(Top)** marked, linear increase of processing time with number of pass-through transforms for
> PipeDreams and Readable-Stream models; Pull-Stream remains unaffected.
>
> **(Bottom)** in terms of
> items (lines) per second (ips), Readable-Stream performance caves in from ~40,000ips to
> around 5,000ips with a mere 100 No-Ops more in the pipeline. PipeDreams presumably worse as it makes heavy
> use of composed stream transforms internally. Pull-Stream remains essentially unaffected; small,
> counter-intuitive *increase* of throughput remains unexplained.





