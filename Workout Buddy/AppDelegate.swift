import UIKit
import FirebaseCore
import GoogleSignIn
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerBackgroundTasks()
        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: - Background Tasks

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.ulvi.workoutbuddy.healthsync",
            using: nil
        ) { task in
            self.handleHealthSyncTask(task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.ulvi.workoutbuddy.gapfill",
            using: nil
        ) { task in
            self.handleGapFillTask(task as! BGProcessingTask)
        }
    }

    private func handleHealthSyncTask(_ task: BGAppRefreshTask) {
        scheduleHealthSyncTask()
        let syncTask = Task {
            await SyncEngine.shared.syncHealthData()
            task.setTaskCompleted(success: true)
        }
        task.expirationHandler = { syncTask.cancel() }
    }

    private func handleGapFillTask(_ task: BGProcessingTask) {
        let fillTask = Task {
            await SyncEngine.shared.performInitialBackfill()
            task.setTaskCompleted(success: true)
        }
        task.expirationHandler = { fillTask.cancel() }
    }

    func scheduleHealthSyncTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.ulvi.workoutbuddy.healthsync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}
