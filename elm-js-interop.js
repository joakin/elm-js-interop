let global =
  typeof window !== "undefined"
    ? window
    : typeof global !== "undefined"
    ? global
    : Function("return this")();

Object.defineProperty(Object.prototype, "__elm_interop", {
  set([code, ...args]) {
    global.args = args;
    try {
      this.__elm_interop_result = eval(`
        (() => {
          try {
            return { tag: 'Ok', result: (${code}) };
          } catch (err) {
            return { tag: 'Error', error: err };
          }
        })();
      `);
    } catch (err) {
      this.__elm_interop_result = { tag: "Error", error: err };
    }
    delete global.args;
  },
  get() {
    return this.__elm_interop_result;
  },
});

let _setTimeout = setTimeout;
let __elm_interop_tasks = new Map();
let __elm_interop_nextTask = null;
Object.defineProperty(Object.prototype, "__elm_interop_async", {
  set([token, code, ...args]) {
    // Async version see setTimeout below for execution
    __elm_interop_nextTask = [token, code, args];
  },
  get() {
    let ret = __elm_interop_tasks.get(this.token);
    __elm_interop_tasks.delete(ret);
    return ret;
  },
});

global.setTimeout = (callback, time, ...args) => {
  if (time === -666 && __elm_interop_nextTask != null) {
    const [token, code, args] = __elm_interop_nextTask;
    __elm_interop_nextTask = null;

    Promise.resolve()
      .then((_) => eval(code))
      .then((result) => {
        __elm_interop_tasks.set(token, { tag: "Ok", result });
      })
      .catch((err) => {
        __elm_interop_tasks.set(token, { tag: "Error", error: err });
      })
      .then((_) => {
        callback();
      });
  } else {
    return _setTimeout(callback, time, ...args);
  }
};
