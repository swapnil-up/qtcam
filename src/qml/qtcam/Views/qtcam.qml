/*
 * qtcam.qml -- display preview in screen
 * Copyright © 2015  e-con Systems India Pvt. Limited
 *
 * This file is part of Qtcam.
 *
 * Qtcam is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 *
 * Qtcam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Qtcam. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import econ.camera.property 1.0
import econ.camera.stream 1.0
import econ.camera.keyEvent 1.0
import econ.camera.fscamcu135 1.0
import econ.camera.see3cam50 1.0
import econ.camera.see3camcu55mh 1.0
import "../JavaScriptFiles/tempValue.js" as JS
import cameraenum 1.0
import econ.camera.uvcsettings 1.0

Rectangle {
    id: root
    //Removed unused signals and property  - By Dhurka - 21st Oct 2016
    signal stopCamPreview()
    signal mouseRightClicked(var x, var y, var width, var height)
    signal mouseRightClickedWithStreamResolution(var x, var y, var previewwindowWidth, var previewwindowHeight, var videoStreamWidth, var videoStreamHeight)
    signal afterBurst()
    signal beforeRecordVideo()
    signal afterRecordVideo()
    signal enableFaceRectafterBurst()
    signal captureFrameTimeout();
    signal autoFocusSelected(bool autoFocusSelect)
    signal autoExposureSelected(bool autoExposureSelect)

    // Added by Sankari : Mar 7 - disable audio settings
    signal disableAudioSettings(bool disableSettings)

    //Added by Sankari: 07 Mar 2017
    // signal to notify auto white balance selected
    signal autoWhiteBalanceSelected(bool autoWhiteBalanceSelect)

    //Added by Sankari: 07 Mar 2017
    // signal to notify whitebalance slider value changed
    signal manualWbSliderValueChanged()
    //To grab preview Frames
    signal queryFrame(bool retriveframe,bool InFailureCase);


    property int burstLength;
    property bool vidFormatChanged: false
    property bool keyEventFiltering :true

    property bool m_Snap : true
    property bool stillPreview : false
    property bool webcamKeyAccept: true
    property bool enableUVCSettings :true

    // Added by Sankari : 25 May 2017, the flag to indicate side bar items are opened/closed
    property bool closeSideBarClicked: false
    property bool getTriggerMode :false

    // Added by Sankari : 25 May 2017, store the status of capture/record button visiblity[used when closing side bar items]
    property bool captureButtonVisibleStatus: false
    property bool videoRecButtonVisibleStatus: false
    property bool recordStopBtnVisibleStatus: false

    // Added by Sankari: 16 Dec 2016
    property bool webcamKeyTriggerShot: true
    property string statusText
    property string videofileName
    property variant see3cam
    //Added by Dhurka - 13th Oct 2016
    //This contains selected camera enum value for comparision instead of camera name
    property int selectedDeviceEnumValue;
    //Added by Dhurka - 19th Oct 2016
    //create object for statusbar qml - Added by Dhurka - 18th Oct 2016
    property variant statusBarRootObject
    property variant aboutViewRootObject
    property variant imageSettingsRootObject
    property variant stillSettingsRootObject
    property variant videoSettingsRootObject
    property variant audioSettingsRootObject
    property variant captureVideoRecordRootObject
    property variant pciBusCamDetails

    //Disabling side bar controls - Added below by Dhurka
    signal sidebarVisibleStatus(variant status);
    signal cameraSettingsTabEnable(variant status);
    //Send control values to imagequalitysettings
    signal setControlValues(string controlName,int controlType,int controlMinValue,int controlMaxValue,int controlStepSize, int controlDefaultValue,int controlID);
    //Disable image settings camera controls
    signal disableImageSettings();
    //Visible state for image settings
    signal videoCaptureFilterChildVisible(bool visibleStatus)
    //Property value for camera controls
    signal cameraControlPropertyChange();
    signal stillFormatChanged(int stillFormatcurrentIndex, int stillResolncurrentIndex);
    property bool videoCaptureChildVisible : false;
    property bool stillCaptureChildVisible: false
    property bool audioCaptureChildVisible: false
    property bool videoSettingsChildVisible: false


    property bool disableAudio: false

    //video scrollview visible height
    property int videoPropHeight

    property int audioPropertyYValue

    property int audioDeviceIndex
    property int audioChannel
    property int audioSampleRate

    //Still properties
    signal stillChildVisibleState(bool visibleStatus)
    //Enable or disable still property item
    signal stillPropertyItemEnable(bool enableStatus)
    //Enable or disable audio property item
    signal audioPropertyItemEnable(bool enableStatus)
    //Insert Still image formats
    signal insertStillImageFormat(var stillFormat);
    signal insertChannelFormats(var channels);
    //Set index of color combox in still property
    signal setColorComboOutputIndex(bool isColorCombo,int indexValue)
    //Image format Y value in the still property
    property int imageFormatYValue
    //Still format Y value in the still property
    property int stillPropertyYValue
    //Default image format Y pos value
    property int defaultImageFormatYValue : 215
    //Default still format y pos value
    property int defaultStillPropertyYValue : 240
    property int defaultVideoPropertyYValue : 275

    // To check mouse click capture function is called
    property bool mouseClickCap: false

    // To disable capture by smile trigger key or external key is pressed when recording video
    property bool disableCaptureImage: false

    // Avaialble FPS list
    property string availableFpslist

    //Added by Sankari - What fps index to change
    property int fpsIndexToChange

    property var fpsList;

    property variant vidstreamObj: vidstreamproperty

    //Video frame interval
    signal videoFrameInterval(int frameInterval)

    // Image Quality settings enable/disable
    signal imageQualitySettingsEnable(bool enableStatus)
    //Video Property item enable or disable
    signal videoPropertyItemEnable(bool enableStatus)
    //Video menu open or closed status
    signal videoChildMenuVisible(bool visibleStatus)
    //Set the video color combo index
    signal setVideoColorComboOutputIndex(bool isColorCombo,int indexValue)
    //Get still property image and still Y pos value
    signal getStillPropertyPositionValues();
    //Update video menu position to move up and down
    signal updateVideoMenuPosition();
    signal updateAudioMenuPosition();
    //Add Auto mode menu item in the image quality settings tab
    signal addAutoModeMenuItem();

    // Query controls when selecting camera
    signal queryUvcControls();

    //Capture and Video Recording
    signal captureBtnEnable(bool enable)
    signal videoRecordBtnEnable(bool enable)
    signal videoRecordBtnVisible(bool visible)

    //Take screen shot for corressponding camera qml file - Added by Dhurka - 7th Nov 2016
    signal takeScreenShot(bool isWebKeyPressed)
    signal getVideoPinStatus()
    signal getStillImageFormats();
    signal cameraDeviceUnplugged();
    signal setMasterMode();
    signal getExposure();

    // Added by Sankari: 16 Dec 2016 - To init trigger shot for 12CUNIR camera
    signal initTriggershot();

    //Added by Sankari: 23 Dec 2016
    signal videoResolutionChanged();

    //Added by Sankari: 25 Dec 2016
    signal videoColorSpaceChanged();

    // Added by Sankari: 11 Jan 2017
    signal previewFPSChanged();

    //Added by Sankari: 04 Jan 2017
    signal stillResolutionChanged(var stillResolution, int stillresolutionIndex, var stillFormat, int stillFormatIndex);


    // Added by Sankari: 3 Jan 2016
    signal frameSkipCount(var stillResolution, var videoResolution, var stillOutFormat);

    signal frameSkipCountWhenFPSChange(var fpsChange);

    // Added by Sankari: 12 sep 2017 - signal to notify the extension tab visibility
    signal extensionTabVisible(bool visible);

    signal cameraSelected();

signal disableStillProp(bool status);
    width:Screen.width
    height:Screen.height
    focus: true

    Action {
        id: cameratab
        onTriggered: {      // Removed selectCameraSettings API inorder to avoid getting camera settings on pressing space key.

        }
    }
    Timer {
        id: recordStartDelayTimer // Record after disabling Auto Focus Rectangle or face rect overlay rectangle
        interval: 1000
        onTriggered: {
            if(disableAudio){
                vidstreamproperty.recordBegin(JS.videoEncoder,JS.videoExtension, videoSettingsRootObject.videoStoragePath, 0, audioSampleRate, audioChannel)
            }
            else{
                vidstreamproperty.recordBegin(JS.videoEncoder,JS.videoExtension, videoSettingsRootObject.videoStoragePath, audioDeviceIndex, audioSampleRate, audioChannel)
            }
            stop()
        }
    }

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        onAccepted: {
            close()
        }
        Component.onCompleted:{
            close()
        }
    }
    // Added by Sankari: To notify user about warning
    // 07 Dec 2017
    MessageDialog {
        id: warningDialog
        icon: StandardIcon.Critical
        onAccepted: {
            close()
        }
        Component.onCompleted:{
            close()
        }
    }
    MessageDialog {
        id: recordFailedDialog
        icon: StandardIcon.Critical
        onAccepted: {
            statusText = "Recording Failed..."
            videoPropertyItemEnable(true)
            stillPropertyItemEnable(true)
            audioPropertyItemEnable(true)
            device_box.enabled = true
            vidstreamproperty.enabled = true
            device_box.opacity = 1
            videoRecordBtnVisible(true)
            uvc_settings.enabled = true
            uvc_settings.opacity = 1
            close()
        }
        Component.onCompleted:{
            close()
        }
    }
    MessageDialog {
        id: recordDisable
        icon: StandardIcon.Critical
        onAccepted: {
            videoPropertyItemEnable(true)
            stillPropertyItemEnable(true)
            audioPropertyItemEnable(true)
            device_box.enabled = true
            vidstreamproperty.enabled = true
            device_box.opacity = 1
            videoRecordBtnVisible(true)
            uvc_settings.enabled = true
            uvc_settings.opacity = 1
            close()
        }
        Component.onCompleted:{
            close()
        }
    }


    Image {
        id: layer_0
        source: "images/layer_0.png"
        x: sideBarItems.visible ? parent.width*0.15 : 0
        y: 0
        opacity: 1
        width: sideBarItems.visible ? parent.width * 0.85 : parent.width
        height: parent.height - statusBarRootObject.statusBarHeight+5
    }

    Rectangle{
        id: previewBgrndArea
        color: "#000000"
        x: layer_0.x
        anchors.left: layer_0.left
        anchors.leftMargin: sideBarItems.visible ? parent.width*0.15 : 0
        width: sideBarItems.visible ? parent.width * 0.85 : parent.width
        height: layer_0.height
    }
    Videostreaming {
        id: vidstreamproperty
        focus: true

        SequentialAnimation on t {
            id:seqAni
            NumberAnimation { to: 1; duration: 16; easing.type: Easing.InQuad }
            NumberAnimation { to: 0; duration: 16; easing.type: Easing.OutQuad }
            loops: Animation.Infinite
            running: false
        }
        // Added by Sankari:12 Feb 2018 - Get the Pci bus info for selected camera
        onPciDeviceBus:{
            pciBusCamDetails = businfo
        }


        onTitleTextChanged:{
            vidstreamproperty.enabled = true
            if(!getTriggerMode)                 //Added by Nivedha: 09 Mar 2021 -- To enable capture and video record button only for master mode
            {
                captureBtnEnable(true)
                videoRecordBtnEnable(true)
            }
            webcamKeyAccept = true
            if(getTriggerMode)
                keyEventFiltering = true
            else
                 keyEventFiltering = false
            messageDialog.title = _title.toString()
            messageDialog.text = _text.toString()
            messageDialog.visible = true
            if(mouseClickCap){
                //Added by Sankari : 08 Mar 2017
                //Enable camera settings/extension settings tab after capturing image
                enableAllSettingsTab()
                mouseClickCap = false
            }
            seqAni.start()
            vidstreamproperty.stopUpdatePreview()

        }
        onEnableRfRectBackInPreview:{
            afterBurst() // signal to do anything need to do after capture continuous[burst] shots.
        }

        // Enable Face detection rect in preview
        onEnableFactRectInPreview:{
            enableFaceRectafterBurst()
        }

        onNewControlAdded: {
            setControlValues(ctrlName.toString(),ctrlType,ctrlMinValue,ctrlMaxValue, ctrlStepSize, ctrlDefaultValue,ctrlID);
        }

        // Added by Navya :31 July 2019
        // To update the preview window width n height only when Application window is resized.
        onSetWindowSize:{
            previewBgrndArea.width = win_width * 0.85
            previewBgrndArea.height = win_height - statusBarRootObject.statusBarHeight+5
            setpreviewWindowSize();
        }

        onDeviceUnplugged: {
            // Added by Sankari:12 Feb 2018 - Get the Pci bus info for selected camera
            keyEvent.stopGetKeyFromCamera()
            seqAni.stop()
            captureBtnEnable(false)
            videoRecordBtnEnable(false)
            keyEventFiltering = true
            statusText = ""
            messageDialog.visible = false
            messageDialog.title = _title.toString()
            messageDialog.text = _text.toString()
            messageDialog.open()
            cameraDeviceUnplugged();
            device_box.oldIndex = 0
            device_box.currentIndex = 0
            enableUVCSettings = false;
            disableImageSettings();
            // Added by Sankari: 25 May 2017. When device is unplugged, make preview area disabled
            vidstreamproperty.enabled = false

            if(captureVideoRecordRootObject.recordStopBtnVisible) {
                statusText = "Saving..."
                vidstreamproperty.recordStop()
                captureVideoRecordRootObject.videoTimerUpdate(false)
                messageDialog.title = qsTr("Saved")
                messageDialog.text = qsTr("Video saved in the location:"+videofileName)
                messageDialog.open()
                videoPropertyItemEnable(true)
                stillPropertyItemEnable(true)
                audioPropertyItemEnable(true)
                device_box.enabled = true
                device_box.opacity = 1
                videoRecordBtnVisible(true)
                uvc_settings.enabled = true
                uvc_settings.opacity = 1
            }
            captureVideoRecordRootObject.captureBtnSelected()       //Added by Nivedha: 09 Mar 2021 -- To enable camera button as default when device is unplugged and reconnected
            if(sideBarItems.visible){ // only when side bar items visible
                //When device is unplugged,need to destroy the active camera qml and create default qml file
                if(see3cam){
                    see3cam.destroy()
                    see3cam = Qt.createComponent("../UVCSettings/others/others.qml").createObject(root)
                    see3cam.visible = !cameraColumnLayout.visible
                    extensionTabVisible(see3cam.visible)
                }
            }
        }

        onLogDebugHandle: {
            camproperty.logDebugWriter(_text.toString())
        }

        onLogCriticalHandle: {
            camproperty.logCriticalWriter(_text.toString())
        }

        onAverageFPS: {
            if(device_box.opacity === 0.5)
            {
                if(!(vidstreamproperty.width == 320 && vidstreamproperty.height ==240)){
                    statusText = "Recording..." + " " + "Current FPS: " + fps + " Preview Resolution: "+ vidstreamproperty.width +"x"+vidstreamproperty.height + " " + "Color Format: " + videoSettingsRootObject.videoColorComboText
                }
            }
            else
            {
                statusText = "Current FPS: " + fps + " Preview Resolution: "+ vidstreamproperty.width +"x"+vidstreamproperty.height + " " + stillSettingsRootObject.captureTime + " " + "Color Format: " + videoSettingsRootObject.videoColorComboText
            }
        }

        onDefaultFrameSize: {
            if(m_Snap) {
                setColorComboOutputIndex(false,outputIndexValue)
            }
            setVideoColorComboOutputIndex(false,outputIndexValue)
            vidstreamproperty.width = defaultWidth
            vidstreamproperty.height = defaultHeight
        }

        onDefaultStillFrameSize: {
            setColorComboOutputIndex(false,outputIndexValue)
        }

        onDefaultOutputFormat: {
            if(m_Snap){
                setColorComboOutputIndex(true,formatIndexValue)
            }
            if(!stillPreview){
                setVideoColorComboOutputIndex(true,formatIndexValue)
            }
        }

        onDefaultFrameInterval:{
            videoFrameInterval(frameInterval)
        }
        onRcdStop: {
            recordFailedDialog.title = "Failed"
            recordFailedDialog.text = recordFail
            recordFailedDialog.open()
            vidstreamproperty.recordStop()
            captureVideoRecordRootObject.videoTimerUpdate(false)
        }
        onVideoRecordInvalid :{
            recordDisable.title = "Disable"
            recordDisable.text = noVideo
            recordDisable.open()
            vidstreamproperty.recordStop()
            captureVideoRecordRootObject.videoTimerUpdate(false)
        }

        onCaptureSaveTime: {
            stillSettingsRootObject.startCaptureTimer(saveTime);
        }

        onVideoRecord: {
            videofileName = fileName
        }

        onStillSkipCount:{
            frameSkipCount(stillResoln, videoResoln, stillOutFormat);
        }

        onStillSkipCountWhenFPSChange:{
            frameSkipCountWhenFPSChange(fpsChange)
        }

        // Added by Sankari - get FPS list
        onSendFPSlist:{
            availableFpslist = fpsList;
        }

        onSignalTograbPreviewFrame:{
            queryFrame(retrieveframe,InFailureCase);
        }

        onCapFrameTimeout:{
            captureFrameTimeout();
        }

        //  Added by Navya : 23 Apr 2019
        //  In order to maintain Mousearea similar to preview window
        onSignalForPreviewWindow:{
            previewwindow.width = resWidth
            previewwindow.height = resHeight
            previewwindow.x = x;
            previewwindow.y = y;
        }

        // Added by Navya : 11 Feb 2020
        // Disabling capturing images while switching Resolutions (false - disable ,true -enable )
        onSignalToSwitchResoln:{
            if(!getTriggerMode)             //Added by Nivedha: 09 Mar 2021 -- To enable capture and video record button only for master mode
            {
                if(switchResoln){
                    keyEventFiltering = false
                    captureBtnEnable(true)
                }
                else {
                    keyEventFiltering = true
                    captureBtnEnable(false)
                }
            }
        }

        Rectangle
        {
            id:previewwindow
            color : "black"

            MouseArea{
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onReleased:
                {
                    if (mouse.button == Qt.LeftButton){
                        if(closeSideBarClicked){
                            captureRecordWhenSideBarItemsClosed()
                        }
                        else{
                            if(captureVideoRecordRootObject.captureBtnVisible && !getTriggerMode ){//Restricts in case of Trigger Modes for FSCAM_CU135 camera.
                                keyEventFiltering = false
                                mouseClickCapture()
                            } else if(captureVideoRecordRootObject.recordBtnVisible && !getTriggerMode ){
                                videoRecordBegin()
                                keyEventFiltering = true         // Added by Navya : To avoid capturing image when video record mode is selected.
                            } else if(captureVideoRecordRootObject.recordStopBtnVisible){
                                videoSaveVideo()
                                keyEventFiltering = true
                            }
                        }
                    }else if(mouse.button == Qt.RightButton){
                        // passing mouse x,y cororinates, preview width and height
                        mouseRightClicked(mouse.x, mouse.y, previewwindow.width, previewwindow.height)
                        mouseRightClickedWithStreamResolution(mouse.x, mouse.y, previewwindow.width, previewwindow.height, vidstreamproperty.width, vidstreamproperty.height)
                    }
                }
            }
        }
    }

    Image {
        id: open_sideBar
        visible: false
        source: "images/open_tab.png"
        anchors.bottom: layer_0.bottom
        anchors.bottomMargin: 50
        anchors.left: layer_0.left
        y: layer_0.height/2 + 20
        opacity: 1
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                open_sideBar.opacity = 1
            }
            onExited: {
                open_sideBar.opacity = 1
            }
            onReleased: {
                closeSideBarClicked = false
                sideBarItems.visible = true
                sidebarVisibleStatus(sideBarItems.visible)
                open_sideBar.visible = false
                // set preview background area. param1:width, param2: height, param3: sidebar visibility true/false
                vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, true)
                vidstreamproperty.sidebarStateChanged()
            }
        }
    }
    Item {
        id: sideBarItems
        Image {
            id: side_bar_bg
            source: "images/side_bar_bg.png"
            x: -3
            y: -5
            height: root.height+5
            opacity: 1
        }
        ComboBox {
            currentIndex: 0
            property int oldIndex: currentIndex
            id: device_box
            x: 18
            y: 110
            opacity: 1
            textRole: "display"
            model: camModels
            activeFocusOnPress : true

            style: ComboBoxStyle {
                background: Image {
                    id: deviceBox
                    source: "images/device_box.png"
                    Rectangle {
                        width: deviceBox.sourceSize.width -28
                        height: deviceBox.sourceSize.height
                        color: "#222021"
                        border.color: "white"
                        border.width: control.activeFocus ? 3 : 1
                        radius: control.activeFocus ? 5 : 0
                    }
                }
                label:  Text{
                    anchors.fill: parent
                    color: "#ffffff"
                    elide: Text.ElideRight
                    text: control.currentText
                    verticalAlignment: Text.AlignVCenter
                    maximumLineCount: 1
                    font.family: "Ubuntu"
                    font.pixelSize: 14
                }
            }
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    if(pressed) {
                        camproperty.checkforDevice()
                    }
                    mouse.accepted = false
                }
                onWheel: {
                }
            }
            onCurrentIndexChanged: {
                if(currentIndex.toString() != "-1" && currentIndex.toString() != "0") {
                    if(oldIndex!=currentIndex) {
                        seqAni.restart
                        // when switching camera make "exposureAutoAvailable" as false
                        imageSettingsRootObject.exposureAutoAvailable = false
                        seqAni.running = true
                        seqAni.start()
                        vidstreamproperty.stopFrameTimeoutTimer()
                        vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, true)

                        oldIndex = currentIndex

                        // Added by Sankari: 12 Feb 2018 : stop Getting key from camera.
                        keyEvent.stopGetKeyFromCamera()
			 if(!is20_04detcted)
                        	enumerateAudioSettings();

                        cameraSelected()
                        //Added by Dhurka - 20th Oct 2016
                        cameraControlPropertyChange();
                        // Added by Sankari: 20 Apr 2017 - If we unplug and plug the camera, the video color space is not updated properly
                        stillPreview = false
                        m_Snap = true
                        captureBtnEnable(true)
                        videoRecordBtnEnable(true)
                        keyEventFiltering = false
                        vidstreamproperty.enabled = true
                        webcamKeyAccept = true

                        vidstreamproperty.stopCapture()
                        vidstreamproperty.closeDevice()
                        selectCameraSettings()
                        camproperty.setCurrentDevice(currentIndex.toString(),currentText.toString())
                        vidstreamproperty.setDevice("/dev/video")
                        vidstreamproperty.displayOutputFormat()
                        vidstreamproperty.displayStillResolution()
                        vidstreamproperty.displayVideoResolution()
                        vidstreamproperty.displayEncoderList()
                        //Added by Dhurka - 24th Oct 2016 - Push Auto mode item in image quality settings for ascella camera
                        addAutoModeMenuItem();
                        //Added by Navya : 18 Feb 2020 -- enabling UVC Settings as it is getting disabled once after device unplugged,leading to disabling exposure control set request for See3CAM_CU30.
                        enableUVCSettings = true
                        //Added by Sankari - 06th Mar 2016
                        queryUvcControls();
                        //Added by Dhurka - 20th Oct 2016
                        disableImageSettings()
                        //Added by Dhurka - Here commonly open HID device instead of open every QML file - 17th Oct 2016
                        openHIDDevice(selectedDeviceEnumValue);

                        // Added by Sankari: 12 Feb 2018 - open camera key event file node using pci bus info.
                        camproperty.openEventNode(pciBusCamDetails)
                        updateFPS(stillSettingsRootObject.stillClorComboValue, stillSettingsRootObject.stillOutputTextValue)

                        vidstreamproperty.width = stillSettingsRootObject.stillOutputTextValue.split("x")[0].toString()
                        vidstreamproperty.height = stillSettingsRootObject.stillOutputTextValue.split("x")[1].toString()
                        vidstreamproperty.lastPreviewResolution(stillSettingsRootObject.stillOutputTextValue,stillSettingsRootObject.stillColorComboIndexValue)
                        JS.stillCaptureFormat = stillSettingsRootObject.stillColorComboIndexValue
                        JS.stillCaptureFormatIndex = stillSettingsRootObject.stillColorComboIndexValue*1
                        JS.stillCaptureResolution = stillSettingsRootObject.stillOutputTextValue.toString()
                        JS.stillCaptureResolutionIndex = stillSettingsRootObject.stillResolutionIndex
                        JS.videoCaptureFormat = JS.stillCaptureFormat
                        JS.videoCaptureResolution = JS.stillCaptureResolution
                        JS.videocaptureFps = videoSettingsRootObject.videoFrameRate
                        // retain lastly set fps index
                        vidstreamproperty.lastFPS(videoSettingsRootObject.videoFrameRateIndex)
                        vidstreamproperty.masterModeEnabled()
                        // Moved by Sankari: Mar 20, 2019. For storage camera, before start preview, we need to set ondemand mode.
                        createExtensionUnitQml(selectedDeviceEnumValue) //setting ondemand mode in fscamcu135 qml oncompleted.
                        vidstreamproperty.startAgain() // Then start preview
                        getStillImageFormats();

                        // Added by Sankari: 12 Feb 2018 - initialize a socket notifier to get key from camera.
                        keyEvent.initializeToGetKey();

                        // Initially enable capture image when external keyevent is occured.
                        disableCaptureImage =  false

                    }
                }
                else {
                    if (currentIndex == 0) {
                        currentIndex = oldIndex
                    }
                }
            }
            Component.onCompleted: {
                camproperty.checkforDevice()
            }
        }
        Button {
            id: camera_settings
            focus: false
            smooth: true
            x: cameraColumnLayout.visible ? 0 : 7
            y: cameraColumnLayout.visible ? 149 : 153
            opacity: 1
            tooltip: "Camera Settings - This settings will have the v4l2 controls for the camera"
            style: tabButtonStyle
            action: cameratab
            activeFocusOnPress: true
            onFocusChanged: {
                if(activeFocus){
                    selectCameraSettings()
                }
            }
        }
        ColumnLayout {
            id: cameraColumnLayout
        }
        Button {
            id: uvc_settings
            smooth: true
            focus: false
            activeFocusOnPress: true
            tooltip: "Extension Settings - Its a special settings available for the individual camera"
            style: ButtonStyle {
                background: Image {
                    source: (!cameraColumnLayout.visible || control.activeFocus) ? "images/toggle_selection.png" : ""
                }
                label: Text {
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    text: qsTr("Extension Settings")
                    font.pixelSize: 14
                    font.family: "Ubuntu"
                    color: "#ffffff"
                }
            }
            x: cameraColumnLayout.visible ? 134 : 130
            y: cameraColumnLayout.visible ? 153 : 149
            opacity: 1
            onFocusChanged: {
                if(activeFocus)
                    extensionTab()
            }
        }
        Component {
            id: econSliderStyle
            SliderStyle {
                groove:Row {
                    spacing: 0
                    y: 3
                    Rectangle {
                        width: styleData.handlePosition
                        height: 4
                        color: "#dc6239"
                        radius: 5
                    }
                    Rectangle {
                        width: control.width - styleData.handlePosition
                        height: 4
                        color: "#dddddd"
                        radius: 5
                    }
                }
                handle: Image {
                    source: "images/handle.png"
                    opacity: 1
                }
            }
        }
        Component {
            id: econTextFieldStyle
            TextFieldStyle {
                textColor: "black"
                background: Rectangle {
                    radius: 2
                    implicitWidth: 50
                    implicitHeight: 20
                    border.color: "#333"
                    border.width: 2
                    y: 1
                }
            }
        }
        Component {
            id: tabButtonStyle
            ButtonStyle {
                background: Image {
                    source: cameraColumnLayout.visible ? "images/toggle_selection.png" : ""
                }
                label: Text {
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    text: qsTr("Camera Settings")
                    font.pixelSize: 14
                    font.family: "Ubuntu"
                    color: "#ffffff"
                }
            }
        }
        Component {
            id: tabSkipButtonStyle
            ButtonStyle {
                background: Image {
                    source: ""
                }
                label: Text {
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    text: qsTr("Camera Settings")
                    font.pixelSize: 14
                    font.family: "Ubuntu"
                    color: "#ffffff"
                }
            }
        }
        Image {
            id: close_sideBar
            source: "images/close_tab.png"
            anchors.bottom: side_bar_bg.bottom
            anchors.bottomMargin: 50
            anchors.right: side_bar_bg.right
            anchors.rightMargin: -28
            y: side_bar_bg.height/2 + 20
            opacity: 1
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    close_sideBar.opacity = 1
                }
                onExited: {
                    close_sideBar.opacity = 1
                }

                onReleased: {
                    // Added by Sankari : 25 May 2017, set the flag to indicate side bar items are closed
                    closeSideBarClicked = true

                    // Added by Sankari : 25 May 2017
                    // Store the last visible status of capture and record buttons when clicking close side bar button
                    captureButtonVisibleStatus = captureVideoRecordRootObject.captureBtnVisible
                    videoRecButtonVisibleStatus = captureVideoRecordRootObject.recordBtnVisible
                    recordStopBtnVisibleStatus = captureVideoRecordRootObject.recordStopBtnVisible

                    if(!cameraColumnLayout.visible)
                        selectCameraSettings()
                    sideBarItems.visible = false
                    sidebarVisibleStatus(sideBarItems.visible)
                    open_sideBar.visible = true
                    // set preview backgrond area. param1:width, param2: height, param3: sidebar visibility true/false
                    vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, false)
                    vidstreamproperty.sidebarStateChanged()
                }
            }
        }
    }
    See3Cam50{
        id:see3camcu50
    }
    Fscamcu135{
        id:fscamcu135
    }
    Uvccamera{
        id: uvccam

    }

    Camproperty {
        id: camproperty

        //Added by Dhurka - 13th Oct 2016
        //This signal is caught from cameraproperty.cpp to get the selected camera enum value
        onCurrentlySelectedCameraEnum:
        {
            selectedDeviceEnumValue = selectedDevice;
        }

        // Added by Sankari: To notify user about warning
        // 07 Dec 2017
        onNotifyUserInfo:{
            warningDialog.title = qsTr(title)
            warningDialog.text = qsTr(text)
            warningDialog.open()
        }
    }

    // Added by Sankari: 12 Feb 2018 - Get the event from keyEventReceive.cpp
    KeyEventRecv{
        id: keyEvent
        onCameraTriggerKeyReceived:{
            m_Snap = false
            if(!disableCaptureImage){ // disable capture by smile trigger key or external key is pressed when recording video
                takeScreenShot(true)
            }
        }
    }

    function enumerateAudioSettings(){
        vidstreamproperty.enumerateAudioProperties()
    }

    function setSampleRate(sampleRate){
        audioSampleRate = sampleRate
        vidstreamproperty.setSampleRate(sampleRate)
    }

    function setChannelCount(channel){
        audioChannel = channel
        vidstreamproperty.setChannelCount(channel)
    }

    // Added by Sankari : Update frame to skip
    function updateFrametoSkip(stillSkip){
        vidstreamproperty.updateFrameToSkip(stillSkip)
    }

    // Added by Sankari: Mar 21, 2019. To set number of frames to skip in preview[ex: in fscam_cu135]
    function updatePreviewFrameskip(previewSkip){
        vidstreamproperty.updatePreviewFrameSkip(previewSkip)
    }


    function retrieveFrameFromStorageCamera(){
        setStillSettings()
        vidstreamproperty.retrieveFrameFromStoreCam()
    }

    function switchToCamFrameSettings(stillSettings){
        // True if swithcing to still settings
        // false if swithcing to preview settings
        vidstreamproperty.switchToStillPreviewSettings(stillSettings)
    }

    function mouseClickCapture() {
        m_Snap = false
        captureBtnEnable(false)
        keyEventFiltering = true
        vidstreamproperty.enabled = false
        mouseClickCap = true
        // Added by Sankari : 25 May 2017,
        // if side bar items are not visible, then enable settings are not needed, after capture image
        if(!closeSideBarClicked){
            //Added by Sankari : 08 Mar 2017
            // Disable camera settings/extension settings tab before capturing image
            imageQualitySettingsEnable(false)
            videoPropertyItemEnable(false)
            stillPropertyItemEnable(false)
            audioPropertyItemEnable(false)
            uvc_settings.enabled = false
            uvc_settings.opacity = 0.5
            selectCameraSettings()
        }
        takeScreenShot(false);
    }

    function updateScenePreview(str, format, fps) {
        m_Snap = false
        if (!vidFormatChanged){
            vidstreamproperty.width = str.toString().split("x")[0].toString()
            vidstreamproperty.height = str.toString().split("x")[1].toString()
        }
        //Added by Navya -To avoid unwanted call for grabPreviewFrame in case of storagecamera by giving delay.
        vidstreamproperty.resolnSwitch()
        if(vidFormatChanged){
            vidstreamproperty.lastPreviewResolution(vidstreamproperty.width.toString() +"x"+vidstreamproperty.height.toString(),format)
            JS.videoCaptureResolution = vidstreamproperty.width.toString() +"x"+vidstreamproperty.height.toString()
        }else{
            vidstreamproperty.lastPreviewResolution(str,format)
        }

        // Added by Sankari: 04 Jan 2017 -  store last fps index
        vidstreamproperty.lastFPS(fps)
        vidstreamproperty.vidCapFormatChanged(format)
        if (!vidFormatChanged){
            vidstreamproperty.setResoultion(str)
        }
        vidstreamproperty.frameIntervalChanged(fps,Videostreaming.FPS_DEFAULT)
        vidstreamproperty.startAgain()
    }

    function updateStillPreview(str, format) {
        m_Snap = false
        stillPreview = true
        vidstreamproperty.stopCapture()
        vidstreamproperty.vidCapFormatChanged(format)
        vidstreamproperty.displayStillResolution()
        vidstreamproperty.setStillVideoSize(str, format)
        JS.videoCaptureFormat = videoSettingsRootObject.videoColorComboIndex
        JS.stillCaptureResolution = stillSettingsRootObject.stillOutputTextValue
        if(JS.videoCaptureFormat !== JS.stillCaptureFormat  || JS.stillCaptureResolution !== JS.videoCaptureResolution)
        {
            vidstreamproperty.vidCapFormatChanged(JS.videoCaptureFormat)
            checkForResoln()      //To set Resolution with the updated one,specially for Hyperyon.
            vidstreamproperty.setResoultion(JS.videoCaptureResolution)
        }
        vidstreamproperty.startAgain()
    }

    // Added by Sankari: 04 Jan 2017
    // Get supported fps list when changing still resolution.And restore the preview resolution.
    function getFPSList(str, format) {
        vidstreamproperty.stopCapture()
        vidstreamproperty.vidCapFormatChanged(JS.stillCaptureFormat)
        vidstreamproperty.setResoultion(JS.stillCaptureResolution)
        vidstreamproperty.updateFrameInterval(stillSettingsRootObject.stillClorComboValue, stillSettingsRootObject.stillOutputTextValue)
        JS.videoCaptureFormat = videoSettingsRootObject.videoColorComboIndex
        JS.stillCaptureResolution = stillSettingsRootObject.stillOutputTextValue
        if(JS.videoCaptureFormat !== JS.stillCaptureFormat  || JS.stillCaptureResolution !== JS.videoCaptureResolution)
        {
            vidstreamproperty.vidCapFormatChanged(JS.videoCaptureFormat)
            vidstreamproperty.setResoultion(JS.videoCaptureResolution)
        }
        vidstreamproperty.startAgain()
    }

    function updateFPS(pix, size) {
        vidstreamproperty.updateFrameInterval(pix, size)
        vidstreamproperty.enumerateFPSList()
    }

    function selectCameraSettings(){
        camera_settings.forceActiveFocus()
        if(!cameraColumnLayout.visible)
        {
            see3cam.visible = false
            extensionTabVisible(false)
        }
        cameraColumnLayout.visible = true
        stillChildVisibleState(false)
        videoCaptureFilterChildVisible(false)
        videoChildMenuVisible(false)
        cameraSettingsTabEnable(true)
    }


    function stopUpdatePreviewInTriggerMode(){
        vidstreamproperty.triggerModeEnabled()
    }

    function startUpdatePreviewInMasterMode(){
        vidstreamproperty.masterModeEnabled()
    }

    function triggerModeCapture(){
        captureBtnEnable(false)
        videoRecordBtnEnable(false)
        keyEventFiltering = true
        vidstreamproperty.enabled = false
        vidstreamproperty.triggerModeEnabled()
        vidstreamproperty.stopCapture()
        vidstreamproperty.vidCapFormatChanged(JS.stillCaptureFormat)
        vidstreamproperty.setResoultion(JS.stillCaptureResolution);
        vidstreamproperty.startAgain();
    }

    function masterModeCapture(){
        if(!captureVideoRecordRootObject.captureBtnEnable || !captureVideoRecordRootObject.recordBtnEnable)  {
            captureBtnEnable(true)
            videoRecordBtnEnable(true)
            vidstreamproperty.enabled = true
            keyEventFiltering = false
        }
        vidstreamproperty.masterModeEnabled()
        if(JS.videoCaptureFormat !== JS.stillCaptureFormat  || JS.stillCaptureResolution !== JS.videoCaptureResolution)
        {
            vidstreamproperty.stopCapture()
            vidstreamproperty.vidCapFormatChanged(JS.videoCaptureFormat)
            vidstreamproperty.setResoultion(JS.videoCaptureResolution);
            vidstreamproperty.startAgain();
        }
    }

    // Added by Navya :13 Aug 2019 --Implemented streamon after switching to master from Trigger mode in case of See3CAM_CU55_MH camera.
    function masterEnableForMonochrome(){
        vidstreamproperty.resolnSwitch();
        vidstreamproperty.vidCapFormatChanged(JS.videoCaptureFormat)
        vidstreamproperty.setResoultion(JS.videoCaptureResolution);
        vidstreamproperty.startAgain();
    }

    function videoRecordBegin() {

        if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_130  || selectedDeviceEnumValue == CommonEnums.SEE3CAM_30){
            recordStartDelayTimer.start() // some delay is required to disable focus rect / face overlay rect. After that delay need to start record.
        }else{
            if(disableAudio){
                vidstreamproperty.recordBegin(JS.videoEncoder,JS.videoExtension, videoSettingsRootObject.videoStoragePath, 0, audioSampleRate, audioChannel)
            }
            else{
                vidstreamproperty.recordBegin(JS.videoEncoder,JS.videoExtension, videoSettingsRootObject.videoStoragePath, audioDeviceIndex, audioSampleRate, audioChannel)
            }
        }

        // Added by Navya - 10 Feb 2020 : Disabling the video record for 320x240 resolution in See3CAM_20CUG camera.
        if(!(vidstreamproperty.width == 320 && vidstreamproperty.height ==240)){
            beforeRecordVideo() // signal to do before starting record video
            // disable capture image when smile trigger key or external camera key when recording video
            disableCaptureImage = true
            keyEventFiltering = true
            captureVideoRecordRootObject.videoTimerUpdate(true)
            videoPropertyItemEnable(false)
            stillPropertyItemEnable(false)
            audioPropertyItemEnable(false)
            device_box.enabled = false
            device_box.opacity = 0.5
            videoRecordBtnVisible(false)
            uvc_settings.enabled = false
            uvc_settings.opacity = 0.5
            if(!videoRecButtonVisibleStatus)
                selectCameraSettings()
        }
    }

    function audioDeviceSelected(currentIndex){
        audioDeviceIndex = currentIndex;
    }

    function videoSaveVideo() {
        if(!(vidstreamproperty.width == 320 && vidstreamproperty.height ==240)){
            statusText = "Saving..."
            vidstreamproperty.recordStop()
            // enable capture image when smile trigger key or external camera key once recording video is finished
            disableCaptureImage = false
            captureVideoRecordRootObject.videoTimerUpdate(false)
            messageDialog.title = qsTr("Saved")
            messageDialog.text = qsTr("Video saved in the location:"+videofileName)
            messageDialog.open()
            videoPropertyItemEnable(true)
            stillPropertyItemEnable(true)
        }
        // Added by Sankari : Apr 5 2018. Once recording is finished, Do not enable audio settings when "YUY" encoder is selected
        if(!disableAudio){
            audioPropertyItemEnable(true)
        }
        device_box.enabled = true
        vidstreamproperty.enabled = true
        device_box.opacity = 1
        keyEventFiltering = false
        videoRecordBtnVisible(true)
        uvc_settings.enabled = true
        uvc_settings.opacity = 1
        afterRecordVideo() // signal to do after finishing record video
    }

    function extensionTab() {
        if(cameraColumnLayout.visible) {
            cameraSettingsTabEnable(false)
            cameraColumnLayout.visible = false
            see3cam.visible = true
            extensionTabVisible(true)
        }
    }

    // Added by Sankari: 25 May 2017
    // Capture and Record When side bar items closed.
    function captureRecordWhenSideBarItemsClosed(){
        if(captureButtonVisibleStatus){
            mouseClickCapture()
        } else if(videoRecButtonVisibleStatus){
            videoRecordBegin()
            // make record start button visibility false
            videoRecButtonVisibleStatus = false
            // make record stop button visibility true
            recordStopBtnVisibleStatus = true
        } else if(recordStopBtnVisibleStatus){
            videoSaveVideo()
            // make record start button visibility true
            videoRecButtonVisibleStatus = true
            // make record stop button visibility true
            recordStopBtnVisibleStatus = false
        }
    }

    function createExtensionUnitQml(selectedDeviceEnumValue){
        if(see3cam){
            see3cam.destroy()
        }
        if(selectedDeviceEnumValue == CommonEnums.ECON_1MP_BAYER_RGB ) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam10/uvc10_c.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.ECON_1MP_MONOCHROME) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam10/uvc10_m.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_11CUG) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam11/uvc11.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.ECON_8MP_CAMERA) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam80/uvc80.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_81) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam81/uvc81.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU50) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam50/uvc50.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU130) {
            see3cam = Qt.createComponent("../UVCSettings/see3camcu130/uvc_cu130.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU135) { // Added By Sankari : 22 Feb 2017
            see3cam = Qt.createComponent("../UVCSettings/see3camcu135/uvc_cu135.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_130) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam130/uvc_130.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_130A) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam130A/uvc_130A.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU51) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam51/uvc51.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_12CUNIR) {
            see3cam = Qt.createComponent("../UVCSettings/see3camar0130/uvc_ar0130.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU40) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam40/uvc40.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU30) {
            see3cam = Qt.createComponent("../UVCSettings/see3camcu30/uvc_cu30.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU38) {
            see3cam = Qt.createComponent("../UVCSettings/see3camcu38/uvc_cu38.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU20) { // Added By Sankari : 28 Jul 2017
            see3cam = Qt.createComponent("../UVCSettings/see3camcu20/see3camcu20.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_30) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam30/uvc_30.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.CX3_UVC_CAM) {
            see3cam = Qt.createComponent("../UVCSettings/ascella/cx3-uvc.qml").createObject(root)
        } else if(selectedDeviceEnumValue == CommonEnums.CX3_SNI_CAM) {
            see3cam = Qt.createComponent("../UVCSettings/cx3SNI/uvcExtCX3SNI.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.NILECAM30_USB) {
            see3cam = Qt.createComponent("../UVCSettings/nilecam30usb/nilecam30_usb.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.ECAM22_USB) {
            see3cam = Qt.createComponent("../UVCSettings/h264cam/h264camExt.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU55) {
            see3cam = Qt.createComponent("../UVCSettings/see3camcu55/see3camcu55.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.FSCAM_CU135){ // Added By Sankari
            see3cam = Qt.createComponent("../UVCSettings/fscamcu135/fscamcu135.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU55_MH) { // Added By Navya
            see3cam = Qt.createComponent("../UVCSettings/see3camcu55_MH/see3camcu55_mh.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_20CUG) { // Added By Navya
            see3cam = Qt.createComponent("../UVCSettings/see3cam20cug/see3cam_20cug.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU22) { // Added By Navya : 11 Dec 2019
            see3cam = Qt.createComponent("../UVCSettings/see3camcu22/see3camcu22.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_130D) { // Added By Navya : 11 Dec 2019
            see3cam = Qt.createComponent("../UVCSettings/see3cam130D/see3cam_130D.qml").createObject(root)//Added by M Vishnu Murali
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_24CUG) {
            see3cam = Qt.createComponent("../UVCSettings/see3cam24cug/see3cam_24cug.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.SEE3CAM_CU81) {
                    see3cam = Qt.createComponent("../UVCSettings/see3cam_cu81/see3cam_cu81.qml").createObject(root)
        }else if(selectedDeviceEnumValue == CommonEnums.ECAM51A_USB || selectedDeviceEnumValue == CommonEnums.ECAM51B_USB ) {
            see3cam = Qt.createComponent("../UVCSettings/ecam51A_USB/ecam51A_usb.qml").createObject(root)
        }
        else {
            see3cam = Qt.createComponent("../UVCSettings/others/others.qml").createObject(root)
        }
        see3cam.visible = false
        extensionTabVisible(false)
    }

    // Added by Sankari : 16 Dec 2016
    // Disable saving image when focus is changed from trigger mode to master mode
    // or changing to any other camera if it is m_saveImage flag set as true to avoid displaying unnecessary pop up dialog.
    // It is used in 12cunir camera. It can be used for other cameras also.
    function disableSaveImage(){
        vidstreamproperty.disableSavingImage()
    }

    //Added by Dhurka - Here commonly open HID device instead of open every QML file - 17th Oct 2016
    function openHIDDevice(selectedEnum)
    {
        switch(selectedEnum)
        {
        case CommonEnums.ECON_1MP_BAYER_RGB:
        case CommonEnums.ECON_1MP_MONOCHROME:
        case CommonEnums.SEE3CAM_11CUG:
        case CommonEnums.SEE3CAM_CU30:
        case CommonEnums.SEE3CAMPLUS_CU30:
            // Added by Sankari : 01 Aug 2017
        case CommonEnums.SEE3CAM_CU20:
        case CommonEnums.SEE3CAM_CU40:
        case CommonEnums.SEE3CAM_CU50:
        case CommonEnums.SEE3CAM_CU51:
        case CommonEnums.SEE3CAM_CU130:
        case CommonEnums.SEE3CAM_12CUNIR:
        case CommonEnums.ECON_8MP_CAMERA:
        case CommonEnums.SEE3CAM_130:
        case CommonEnums.SEE3CAM_130A:
        case CommonEnums.SEE3CAM_30:
        case CommonEnums.SEE3CAM_81:
            // Added by Sankari : 22 Feb 2017
        case CommonEnums.SEE3CAM_CU135:
        case CommonEnums.NILECAM30_USB:
        case CommonEnums.SEE3CAM_CU55:
        case CommonEnums.FSCAM_CU135:
        case CommonEnums.SEE3CAM_CU38:

            // Added by Navya
        case CommonEnums.SEE3CAM_CU55_MH:
        case CommonEnums.SEE3CAM_20CUG:
        case CommonEnums.SEE3CAM_CU22:
        case CommonEnums.SEE3CAM_130D: //Added by M.VishnuMurali
        case CommonEnums.SEE3CAM_24CUG:
        case CommonEnums.SEE3CAM_CU81:
            camproperty.openHIDDevice(device_box.currentText);
            break;
        }
    }

    Component.onCompleted: {
        camproperty.createLogger()
        //When No camera is selected, click extension tab need to display no extension settings message
        if(device_box.currentIndex == 0)
        {
            see3cam = Qt.createComponent("../UVCSettings/others/others.qml").createObject(root)
            see3cam.visible = false
            extensionTabVisible(false)
        }
        //Added below components by Dhurka
        //Status Bar view
        var statusbarComponent = Qt.createComponent("statusbar.qml")
        if (statusbarComponent.status === Component.Ready)
        {
            statusBarRootObject = statusbarComponent.createObject(root);
        }
        //About view
        var aboutViewComponent = Qt.createComponent("aboutview.qml")
        if (aboutViewComponent.status === Component.Ready)
        {
            aboutViewRootObject = aboutViewComponent.createObject(root,{"statusBarHeight":statusBarRootObject.statusBarHeight});
        }
        //Image Quality settings view
        var imageViewComponent = Qt.createComponent("imagequalitysettings.qml")
        if (imageViewComponent.status === Component.Ready)
        {
            imageSettingsRootObject = imageViewComponent.createObject(root,{});
        }
        disableImageSettings()
        //Still capture settings view
        var stillViewComponent = Qt.createComponent("stillcapturesettings.qml")
        if (stillViewComponent.status === Component.Ready)
        {
            stillSettingsRootObject = stillViewComponent.createObject(root,{});
        }
        //Video capture settings view
        var videoViewComponent = Qt.createComponent("videocapturesettings.qml")
        if (videoViewComponent.status === Component.Ready)
        {
            videoSettingsRootObject = videoViewComponent.createObject(root,{"imageFormatY" : imageFormatYValue,"stillPropertyY" : stillPropertyYValue});
        }
        if(!is20_04detcted)
        {
            var AudioViewComponent = Qt.createComponent("audiocapturesettings.qml")
            if (AudioViewComponent.status === Component.Ready)
            {
                audioSettingsRootObject = AudioViewComponent.createObject(root,{"imageFormatY" : imageFormatYValue,"stillPropertyY" : stillPropertyYValue});
            }
        }
        //Capture and Video recording
        var captureVideoRecordComponent = Qt.createComponent("captureandvideorecord.qml")
        if (captureVideoRecordComponent.status === Component.Ready)
        {
            captureVideoRecordRootObject = captureVideoRecordComponent.createObject(root,{});
        }
    }
    Component.onDestruction: {
        // Stop the timer when quitting application
        vidstreamproperty.stopFrameTimeoutTimer();
        if(captureVideoRecordRootObject.recordStopBtnVisible) {
            vidstreamproperty.recordStop()
            captureVideoRecordRootObject.videoTimerUpdate(false)
        }
        vidstreamproperty.stopCapture()
        camproperty.closeLibUsbDeviceAscella()
        setMasterMode();
        // Added by Sankari: 12 Feb 2018 - stop Getting key from camera.
        keyEvent.stopGetKeyFromCamera()
    }

    Keys.onReleased: {
        if(event.key === Qt.Key_I) {
            if((!keyEventFiltering  && !getTriggerMode)) {      //Added by Nivedha: 09 Mar 2021 -- To enable capturing images only for master mode
                mouseClickCapture()
            }
        }
    }

    Keys.onLeftPressed: {
        // Added by Sankari : 25 May 2017, set the flag to indicate side bar items are closed
        closeSideBarClicked = true

        // Added by Sankari : 25 May 2017
        // Store the last visible status of capture and record buttons when clicking close side bar button
        captureButtonVisibleStatus = captureVideoRecordRootObject.captureBtnVisible
        videoRecButtonVisibleStatus = captureVideoRecordRootObject.recordBtnVisible
        recordStopBtnVisibleStatus = captureVideoRecordRootObject.recordStopBtnVisible

        if(!cameraColumnLayout.visible)
            selectCameraSettings()
        sideBarItems.visible = false
        sidebarVisibleStatus(sideBarItems.visible)
        open_sideBar.visible = true

        // Added by Sankari: 05 Apr 2019
        // set preview background area. param1:width, param2: height, param3: sidebar visibility true/false
        vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, false)
        vidstreamproperty.sidebarStateChanged()
    }

    Keys.onRightPressed: {
        // Added by Sankari : 25 May 2017, set the flag to indicate side bar items are opened
        closeSideBarClicked = false
        // Added by Sankari : 15 Dec 2017 , when right key pressed, hide extension unit and open camera settings tab
        see3cam.visible  = false
        camera_settings.forceActiveFocus()
        sideBarItems.visible = true
        sidebarVisibleStatus(sideBarItems.visible)
        open_sideBar.visible = false

        // Added by Sankari: 05 Apr 2019 - To prevent overlapping preview with side bar.
        // set preview background area. param1:width, param2: height, param3: sidebar visibility true/false
        vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, true)
        vidstreamproperty.sidebarStateChanged()
   }

    function enableAllSettingsTab(){
        imageQualitySettingsEnable(true)
        videoPropertyItemEnable(true)
        stillPropertyItemEnable(true)
        if(disableAudio){
            audioPropertyItemEnable(false)
        }else{
            audioPropertyItemEnable(true)
        }
        uvc_settings.enabled = true
        uvc_settings.opacity = 1
        captureBtnEnable(true)
        keyEventFiltering = false
        vidstreamproperty.enabled = true
    }

    // Added by Sankari: 23 Dec 2016 - emit the signal to inform video resolution is changed in video capture settings
    function informVideoResoutionChanged(){
        videoResolutionChanged()
    }

    function informPreviewFPSChanged(){
        previewFPSChanged()
    }
    function skipFrameInPreview(skipFrame){
        vidstreamproperty.setSkipPreviewFrame(skipFrame)
    }


    // Added by Sankari: 25 Dec 2016 - emit the signal to inform video color space is changed in video capture settings
    function informVideoColorSpaceChanged(){
        videoColorSpaceChanged()
    }

    function informStillResolutionIndexChanged(resoln, resolutionIndex,format,stillFormatIndex){
        stillResolutionChanged(resoln, resolutionIndex, format, stillFormatIndex)
    }

    // Added by Sankari - 9 Dec 2016
    function takeTriggershot(){
        // Before processing , disable webcam keys
        webcamKeyTriggerShot = false

        // Capture shot
        imageCapture(CommonEnums.TRIGGER_SHOT)

        // After processing , enable webcam keys
        webcamKeyTriggerShot = true
    }

    //Added below by Dhurka - 24th Oct 2016
    function stillBurstLength(burstLen)
    {
        burstLength = burstLen
    }
    //for taking snap shot
    function imageCapture(shotType)
    {
        seqAni.stop()
        vidstreamproperty.setFpsOnCheckingFormat(stillSettingsRootObject.stillClorComboValue)
        vidstreamproperty.setStillVideoSize(stillSettingsRootObject.stillOutputTextValue, stillSettingsRootObject.stillColorComboIndexValue)
        switch(shotType)
        {
        case CommonEnums.SNAP_SHOT:
            vidstreamproperty.makeShot(stillSettingsRootObject.stillStoragePath,stillSettingsRootObject.stillImageFormatComboText)
            break;
        case CommonEnums.STORECAM_RETRIEVE_SHOT:
            vidstreamproperty.retrieveShotFromStoreCam(stillSettingsRootObject.stillStoragePath,stillSettingsRootObject.stillImageFormatComboText)
            break;
        case CommonEnums.TRIGGER_SHOT:
            vidstreamproperty.triggerModeShot(stillSettingsRootObject.stillStoragePath,stillSettingsRootObject.stillImageFormatComboText)
            break;
        case CommonEnums.BURST_SHOT:
            vidstreamproperty.makeBurstShot(stillSettingsRootObject.stillStoragePath,stillSettingsRootObject.stillImageFormatComboText, burstLength)
            break;
        case CommonEnums.CHANGE_FPS_SHOT:
            vidstreamproperty.changeFPSandTakeShot(stillSettingsRootObject.stillStoragePath,stillSettingsRootObject.stillImageFormatComboText, fpsIndexToChange)
            break;
        }
    }
    function enableCameraControls()
    {
        stillChildVisibleState(false)
        videoChildMenuVisible(false)
    }
    //get still settings from camera[used in storagecam] and Update in UI
    function changeStillSettings(stillFormat, stillResolution){ // still capture settings in UI
        setColorComboOutputIndex(true, stillFormat-1) // setting still format in UI
        setColorComboOutputIndex(false, stillResolution-1) // setting still resolution in UI
        JS.stillCaptureFormat = stillSettingsRootObject.stillColorComboIndexValue
        JS.stillCaptureFormatIndex = stillSettingsRootObject.stillColorComboIndexValue*1
        JS.stillCaptureResolution = stillSettingsRootObject.stillOutputTextValue.toString()
        JS.stillCaptureResolutionIndex = stillSettingsRootObject.stillResolutionIndex
    }
    function setStillSettings()
    {
        vidstreamproperty.setStillVideoSize(stillSettingsRootObject.stillOutputTextValue, stillSettingsRootObject.stillColorComboIndexValue)
    }
    function logInfo(log)
    {
        camproperty.logDebugWriter(log)
    }
    function changeCameraSettings(controlId,value)
    {
        vidstreamproperty.changeSettings(controlId,value.toString())
    }
    function selectMenuIndex(controlId,index)
    {
        if(enableUVCSettings)
            vidstreamproperty.selectMenuIndex(controlId,index)
        else
            enableUVCSettings = true;
    }
    function cameraFilterControls(value)
    {
        vidstreamproperty.cameraFilterControls(value)
    }
    function updateVideoResolution(colorComboText,frameRateIndex)
    {
        root.updateScenePreview(vidstreamproperty.width.toString() +"x"+vidstreamproperty.height.toString(),colorComboText,frameRateIndex)
        vidstreamproperty.displayVideoResolution()
        vidstreamproperty.lastPreviewResolution(vidstreamproperty.width.toString() +"x"+vidstreamproperty.height.toString(),colorComboText)
    }
    function imageSettingVisibleChanged()
    {
        if(videoCaptureChildVisible)
        {
            getStillPropertyPositionValues();
        }
        else
        {
            imageFormatYValue = defaultImageFormatYValue
            stillPropertyYValue = defaultStillPropertyYValue
        }
        updateVideoMenuPosition();
        updateAudioMenuPosition();
    }
    function enableVideoPin(videoPinEnable)
    {
        videoSettingsRootObject.enableVideoPin(videoPinEnable)
    }
    function enableTimerforGrabPreviewFrame(timerstatus)
    {
        vidstreamproperty.enableTimer(timerstatus);
    }

    // Added by Navya -To avoid crash in case of Hyperyon by setting correct resoln
    function checkForResoln()
    {
        JS.videoCaptureResolution = videoSettingsRootObject.videoOutputSize
    }

    //Added by Navya - 29 May 2019 -- Inorder to stop VideoRecord and Image Capture in case of Trigger Mode.
    function checkForTriggerMode(mode)
    {
        getTriggerMode = mode;
        if(mode)
            keyEventFiltering = true;
        else
        {
            keyEventFiltering = false;
            seqAni.start()                  //Added by Nivedha: 09 Mar 2021 -- To start sequential animation which was stopped during image capture in trigger mode
        }
    }

    //Added by Navya - 3rd June 2019 -- Disabling powerLine Frequency due to mismatch in set and get controls from HID and v4l2.
    function disablePowerLineFreq()
    {
        imageSettingsRootObject.controlPowerLineFreq()
    }

    //Added by Navya -12 June 2019 -- Getting exposure compensation only after setting resolution for See3CAM_CU55 camera.
    function getExposureOnResolnCheck()
    {
        checkForResoln()
        vidstreamproperty.setResoultion(JS.videoCaptureResolution)
        getExposure()
    }
    // Added by Navya -31 July 2019 --Updating Preview display area when Application window is resized.
    function setpreviewWindowSize(){
        if(closeSideBarClicked){
            vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, false)
        }
        else{
            vidstreamproperty.setPreviewBgrndArea(previewBgrndArea.width, previewBgrndArea.height, true)
        }
    }
}
