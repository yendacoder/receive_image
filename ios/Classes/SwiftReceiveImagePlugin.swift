import Flutter
import UIKit

public class SwiftReceiveImagePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var initialImage: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "receive_image", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "receive_image/files", binaryMessenger: registrar.messenger())

    let instance = SwiftReceiveImagePlugin()

    eventChannel.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getInitialFile":
        result(initialImage)
        initialImage = nil
        break
      default:
        result(FlutterMethodNotImplemented)
        break
    }
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink) -> FlutterError? {

    self.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  // call this to save the link and send to the flutter stream if one is connected
  // the file needs to be copied over to the NSCachesDirectory first
  private func handleLink(url: URL) -> Void {
    let link = url.absoluteString
    initialImage = link

    guard let _eventSink = eventSink, link != nil else {
      return
    }

    _eventSink(link)
  }
}
