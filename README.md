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

## Build order

Each of the four projects is a standard OMNeT++ project. Build them in this order:

```text
inet4.5  ->  tcpPaced  ->  tcpGoodputApplications  ->  bbr
```