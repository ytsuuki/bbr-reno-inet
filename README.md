# bbr-reno-inet

Comparative study of BBRv1 and Reno in OMNeT++ / INET, reproducing the sharing
behaviour reported in Sarpkaya et al., *BBR's Sharing Behavior with CUBIC and Reno*
(arXiv:2505.07741), Figure 2(c).

---

## Layout

| path | contents |
|---|---|
| `bbr/` | BBRv1 and BBRv3 implementation (based on Avian688/bbr), as a standalone OMNeT++ project |
| `inet4.5/` | INET 4.5.4, with the TCP extensions the BBR project needs |
| `tcpPaced/` | paced TCP, required by `bbr` |
| `tcpGoodputApplications/` | application support, required by `bbr` |
| `ned/` | the network used for all experiments |
| `ini/` | simulation configuration |

**BBR is not part of INET.** It is a separate OMNeT++ project that links against the
other three at run time.

---

## Where to look

| what | file |
|---|---|
| BBRv1 algorithm (state machine, pacing, cwnd, filters) | `bbr/src/transportlayer/bbr/flavours/BbrFlavour.cc` |
| BBRv1 state variables and constants | `bbr/src/transportlayer/bbr/flavours/BbrFamilyState.msg` |
| BBR module parameters, settable from `omnetpp.ini` | `bbr/src/transportlayer/bbr/Bbr.ned` |
| TCP base class used by Reno / NewReno / CUBIC | `inet4.5/src/inet/transportlayer/tcp/flavours/TcpBaseAlg.cc` |
| Reno flavour | `inet4.5/src/inet/transportlayer/tcp/flavours/TcpReno.cc` |
| network topology | `ned/BbrDumbbell.ned` |
| simulation configuration | `ini/omnetpp.ini` |

---

## Recent change: BBR constants moved into `omnetpp.ini`

Previously these were compile-time constants scattered through the C++ source, so every
parameter experiment required an edit and a rebuild. They are now NED parameters on the
`Bbr` module and can be set per-config, e.g.

```ini
**.clientB.tcp.bbrCwndGain = 1.71
**.clientB.tcp.bbrProbeRttDuration = 0.2s
```

| parameter | default (BBRv1 specification) |
|---|---|
| `bbrHighGain` | 2.89 |
| `bbrCwndGain` | 2.0 |
| `bbrCwndGainProbeRtt` | 1.0 |
| `bbrInitialCwndMss` | 4 |
| `bbrMinPipeCwndMss` | 4 |
| `bbrSendQuantumMss` | 1 |
| `bbrBwWindowRounds` | 10 |
| `bbrProbeRttDuration` | 0.2 s |
| `bbrMinRttFilterLen` | 10 s |
| `bbrPacingMargin` | 0.01 |

Defaults reproduce the specification values, so an unmodified configuration behaves
exactly as before.

---

## Experiment setup

| item | value |
|---|---|
| topology | 1 sender + 1 receiver per flow, two routers, one shared bottleneck |
| access links | 100 Mbps, 1 ms |
| bottleneck | 10 Mbps, 18 ms each way (RTT 40 ms) |
| BDP | 50 kB ≈ 34 packets of 1500 B |
| queue | drop-tail, capacity set in BDP multiples |
| TCP | MSS 1460, SACK on, delayed ACKs off, Nagle off |
| run length | 200 s |

---

## What the measurements show

BBR's internal estimates, read directly from the exported vectors at 1 BDP:

```text
maxBandwidthFilter   median  9.69 Mbps   (bottleneck is 10.00; no sample exceeds it)
minRtt               median 41.49 ms     (40 ms propagation + 1.2 ms serialisation)
pacingGain share     1.25 : 0.75 : 1.0 = 14.9% : 12.1% : 73.0%   (nominal 12.5 / 12.5 / 75)
estimatedBdp         median 50,247 B
cwnd                 median 104,874 B
```

All the estimates are correct. But

```text
cwnd     = 2 x 50,247 + quanta = 104,874 B
capacity = pipe (50,000) + queue (50,000) = 100,000 B
```

The window is about 5% larger than the whole system. That is not an estimation error: it
is what `cwnd_gain = 2.0` produces once the BDP estimate is accurate, at one BDP of
buffering. The consequence is that the queue never empties and the competing Reno flow
is starved.

The outcome is correspondingly sensitive to the window. Sweeping `cwnd_gain` at 1 BDP:

| `bbrCwndGain` | BBR share |
|---|---|
| 2.00 | 0.999 |
| 1.80 | 0.926 |
| 1.71 | 0.797 |
| 1.60 | 0.633 |

The paper reports 0.80 at one BDP. `gain = 1.71` reproduces it.

Across buffer sizes we obtain 0.999 / 0.409 / 0.292 at 1 / 2 / 4 BDP, against the
paper's 0.888 / 0.630 / 0.479.

---

## Running

```bash
cd BbrDumbbell
opp_run -u Cmdenv -c test \
  -n .:/path/to/bbr/src:/path/to/inet4.5/src:/path/to/tcpPaced/src:/path/to/tcpGoodputApplications/src \
  -l /path/to/bbr/src/bbr \
  -l /path/to/inet4.5/src/INET \
  -l /path/to/tcpGoodputApplications/src/tcpGoodputApplications \
  -l /path/to/tcpPaced/src/tcpPaced \
  omnetpp.ini
```

Build: each of the four projects is a standard OMNeT++ project; build them in the order
`inet4.5` → `tcpPaced` → `tcpGoodputApplications` → `bbr`.