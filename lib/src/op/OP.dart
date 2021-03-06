part of memcached_client;

abstract class OP {
  List<int> get cmd;
  OPState get state;
  void set state(OPState state);
  int get seq;
  void set seq(int s);

  /**
   * Returns whether this OP is canceled by the user.
   */
  bool get isCancelled => state == OPState.CANCELED;

  /**
   * Cancel this OP if not processed yet(still in write queue).
   */
  void cancel() {
    if (state == OPState.WRITE_QUEUED)
      state = OPState.CANCELED;
  }

  /**
   * To be overriden. Handle a response command line; return the size of the
   * data block per the command line.
   *
   * + return _HANDLE_COMPLETE to complete the operation.
   * + return _HANDLE_CMD to continue another command line.
   * + return >= 0 to tell the data block size to read data block.
   */
  int handleCommand(List<int> respcmd);

  /**
   * To be overriden. Handle response data block.
   *
   * + return _HANDLE_COMPLETE to complete the operation.
   * + return _HANDLE_CMD to continue another command line.
   * + return >= 0 the data block size to read data block.
   */
  int handleData(List<int> data);

  /**
   * Transition to next state.
   */
  void nextState() {
    if (state == null)
      state = OPState.WRITE_QUEUED;
    else if (state == OPState.WRITE_QUEUED)
      state = OPState.WRITING;
    else if (state == OPState.WRITING)
      state = OPState.READING;
    else if (state == OPState.READING)
      state = OPState.COMPLETE;
    else if (state == OPState.RETRY)
      state = OPState.WRITE_QUEUED;
    else if (state == OPState.CANCELED)
      state = OPState.COMPLETE;
  }

  /**
   * Indicate the completion of processing an OP.
   */
  void complete() {
    state = OPState.COMPLETE;
  }
}

abstract class DeleteOP extends OP implements FutureOP<bool> {}

abstract class GetOP extends OP implements StreamOP<GetResult> {}

abstract class GetSingleOP extends OP implements FutureOP<GetResult> {}

abstract class MutateOP extends OP implements FutureOP<int> {}

abstract class StoreOP extends OP implements FutureOP<bool> {}

abstract class TouchOP extends OP implements FutureOP<bool> {}

abstract class VersionOP extends OP implements FutureOP<String> {}

/** Base operation implementation */
final _SPACE = encodeUtf8(' ').first;
final _CRLF = encodeUtf8('\r\n');
final _CR = encodeUtf8('\r').first;
final _LF = encodeUtf8('\n').first;

/** Result of handle operation command */
const int _HANDLE_COMPLETE = -3;
const int _HANDLE_CMD = -2;
