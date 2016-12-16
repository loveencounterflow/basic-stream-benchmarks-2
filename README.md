# basic-stream-beanchmarks-2

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

> Charts: **(Top)** marked, linear increase of processing time with number of pass-through transforms for
> PipeDreams and Readable-Stream models; Pull-Stream remains unaffected.—**(Bottom)** in terms of
> items (lines) per second (ips) of throughput, Readable-Stream performance caves in from ~40,000ips to
> around 5,000ips with a mere 100 No-Ops more in the pipeline. PipeDreams presumably worse as it makes heavy
> use of composed stream transforms internally. Pull-Stream remains essentially uneffected; small,
> counter-intuitive *increase* of throughput remains unexplained.





