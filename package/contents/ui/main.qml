/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    property string cmd_warm : 'cat /sys/class/backlight/backlight_warm/brightness'
    property string cmd_cool : 'cat /sys/class/backlight/backlight_cool/brightness'
    property int brightness_warm: 0
    property int brightness_cool: 0

    PlasmaCore.DataSource {
		id: executable_cool
		engine: "executable"
		connectedSources: []
		onNewData: {
			var exitCode = data["exit code"]
			var exitStatus = data["exit status"]
			var stdout = data["stdout"]
			var stderr = data["stderr"]
			exited(exitCode, exitStatus, stdout, stderr)
			disconnectSource(sourceName) // cmd finished
            brightness_cool = stdout
		}
		function exec(cmd) {
			connectSource(cmd)
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
	}

    PlasmaCore.DataSource {
		id: executable_warm
		engine: "executable"
		connectedSources: []
		onNewData: {
			var exitCode = data["exit code"]
			var exitStatus = data["exit status"]
			var stdout = data["stdout"]
			var stderr = data["stderr"]
			exited(exitCode, exitStatus, stdout, stderr)
			disconnectSource(sourceName) // cmd finished
            brightness_warm = stdout
		}
		function exec(cmd) {
			connectSource(cmd)
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
	}

    PlasmaCore.DataSource {
		id: set_brightness
		engine: "executable"
		connectedSources: []
		onNewData: {
			var exitCode = data["exit code"]
			var exitStatus = data["exit status"]
			var stdout = data["stdout"]
			var stderr = data["stderr"]
			console.log(stdout)
            console.log(stderr)
			exited(exitCode, exitStatus, stdout, stderr)
			disconnectSource(sourceName) // cmd finished
		}
		function exec(cmd) {
			connectSource(cmd)
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
	}


	Component.onCompleted: {
		executable_cool.exec(cmd_cool)
        executable_warm.exec(cmd_warm)
	}

	Timer {
        interval: 500; running: true; repeat: true
        onTriggered: {
            executable_cool.exec(cmd_cool)
            executable_warm.exec(cmd_warm)
        }
    }

    Plasmoid.fullRepresentation: ColumnLayout {
        RowLayout {
            Image {
                Layout.fillWidth: true
                Layout.maximumHeight: 30
                fillMode: Image.PreserveAspectFit
                source: "../images/sun.svg"
            }
            PlasmaComponents3.Slider {
                id: slider_cool
                Layout.fillWidth: true
                Layout.maximumHeight: 30
                from: 0
                to: 2550
                value: brightness_cool
                stepSize: 8
                onValueChanged: {
                    console.log(value);
                    set_brightness.exec("echo " + value + " >  /sys/class/backlight/backlight_cool/brightness");
                }

            }
        }
        RowLayout {
            Image {
                Layout.fillWidth: true
                Layout.maximumHeight: 30
                fillMode: Image.PreserveAspectFit
                source: "../images/moon.svg"
            }
            PlasmaComponents3.Slider {
                id: slider_warm
                Layout.fillWidth: true
                from: 0
                to: 2550
                value: brightness_warm
                stepSize: 8
                onValueChanged: {
                    console.log(value);
                    set_brightness.exec("echo " + value + " >  /sys/class/backlight/backlight_warm/brightness");
                }
            }
        }
    }
}
