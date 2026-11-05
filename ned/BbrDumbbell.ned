import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.inet.StandardHost;
import inet.node.inet.Router;
import ned.DatarateChannel;

// Two-flow dumbbell for BBRv1 vs Reno/NewReno experiments.
//
// clientB --1ms--\
//                 router1 == 40Mbps / 3ms == router2 --1ms-- serverB
// clientR --1ms--/                                      \--1ms-- serverR
//
// One-way propagation delay = 1 + 3 + 1 = 5 ms
// Base RTT = 10 ms
// BDP at 40 Mbps = 40e6 * 0.01 / 8 = 50,000 bytes ~= 34 packets (1500 B)

network BbrDumbbell
{
    types:
        channel AccessLink extends DatarateChannel
        {
            datarate = 100Mbps;
            delay = 1ms;
        }

        channel BottleneckLink extends DatarateChannel
        {
            datarate = 40Mbps;
            delay = 3ms;
        }

    submodules:
        configurator: Ipv4NetworkConfigurator {
            @display("p=500,60");
        }

        clientB: StandardHost {
            @display("p=100,180");
        }

        clientR: StandardHost {
            @display("p=100,380");
        }

        router1: Router {
            @display("p=330,280");
        }

        router2: Router {
            @display("p=670,280");
        }

        serverB: StandardHost {
            @display("p=900,180");
        }

        serverR: StandardHost {
            @display("p=900,380");
        }

    connections:
        clientB.pppg++ <--> AccessLink <--> router1.pppg++;
        clientR.pppg++ <--> AccessLink <--> router1.pppg++;

        router1.pppg++ <--> BottleneckLink <--> router2.pppg++;

        router2.pppg++ <--> AccessLink <--> serverB.pppg++;
        router2.pppg++ <--> AccessLink <--> serverR.pppg++;
}
