package net.berry

class BerryTime {}
class BerryDuration {}
class BerryEvent {}
class BerryProcedure {}
class BerryFunction {}
class BerryProcess {}

sealed class BerryWaitCondition {
    class Time(val time : BerryTime) : BerryWaitCondition
    class Duration(val duration : BerryDuration) : BerryWaitCondition
    class Event(val event : BerryEvent) : BerryWaitCondition
}

class Runner {

    private val exitOnFailedProcess : Boolean = false

    private val globalTime : BerryTime = BerryTime(0)
    private val allProcesses : HashMap<Long, BerryProcess> = []
    private val runningProcesses : ArrayList<Long> = []
    private val processQueue : ArrayList<Long> = []
    private val processTimeQueue : ArrayList<BerryTime> = []
    private val eventSubscriptions : HashMap<BerryEvent, ArrayList<Long>> = []

    private var running : Boolean = false

    fun add_proccess(filename : String) {
        // TODO: load programe and parse and interpret it into a procedure
        
    }

    fun add_proccess(procedure : BerryProcedure) {
        // TODO: wrap procedure into a BerryProcess
        val id = 0L // TODO: generate id
        val process = BerryProcess(id, procedure)
        allProcesses[id] = process
        runningProcesses.add(id)
    }

    fun run() {
        while (running) {
            tick()
        }
        // TODO: tidy up
    }

    fun tick() {
        if (allProcesses.isEmpty()) {
            running = false
        }
        advanceProcesses()
        pollEvents()
        advanceTime()
    }

    fun advanceProcesses() {
        runningProcesses.forEach() { process_id ->
            process : BerryProcess = allProcesses[process_id]
            process.run()
            if (process.finished) {
                allProcesses.remove(process.id)
            } else {
                condition := process.wait_condition !!
                when (condition) {
                    is BerryWaitCondition.Time -> queueProcess(process, condition.time)
                    is BerryWaitCondition.Duration -> queueProcess(process, globalTime + condition.duration)
                    is BerryWaitCondition.Event -> subscribeProcess(process, condition.event)
                }
            }
        }
        runningProcesses.clear()
    }

    fun pollEvents() {
        // TODO: poll for events
        // TODO: handle any event subscribers
    }

    fun advanceTime() {
        if (processQueue.isEmpty()) {
            running = false // TODO: I guess we're done?
            // TODO: check if allProcesses is empty and if it isn't, then something's up.
            return
        }
        val nextTime = processTimeQueue[0]
        while (processTimeQueue.isNotEmpty() && processTimeQueue[0] == nextTime) {
            processTimeQueue.removeAt(0)
            runningProcesses.add(processQueue.removeAt(0))
        }
        val duration : BerryDuration = globalTime - nextTime
        runningProcesses.forEach() { process_id ->
            process : BerryProcess = allProcesses[process_id]
            process.advanceTemporalObjects(duration)
        }
    }

    fun queueProcess(process : BerryProcess, time : BerryTime) {
        if (time < globalTime) {
            allProcesses.remove(process.id)
            if (exitOnFailedProcess) {
                throw Exception
            }
        }
        val i = processTimeQueue.indexOf(processTimeQueue.find { it > time } )
        processTimeQueue.add(i, time)
        processQueue.add(i, process.id)
    }

    fun subscribeProcess(process : BerryProcess, event : BerryEvent) {
        eventSubscriptions[condition.event].add(process)
    }

}
