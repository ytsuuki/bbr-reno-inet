//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//

package bbr.transportlayer.bbr;

import tcppaced.transportlayer.tcp.TcpPaced;

simple Bbr extends TcpPaced
{
    parameters:
        @class("inet::tcp::Bbr");


        double bbrHighGain = default(2.89);
        double bbrCwndGain = default(2.0);
        double bbrCwndGainProbeRtt = default(1.0);
        int    bbrInitialCwndMss = default(4);
        int    bbrMinPipeCwndMss = default(4);
        int    bbrSendQuantumMss = default(1);
        int    bbrBwWindowRounds = default(10);
        double bbrProbeRttDuration @unit(s) = default(0.2s);
        double bbrMinRttFilterLen @unit(s) = default(10s);
        double bbrPacingMargin = default(0.01);
}