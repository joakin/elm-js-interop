var p = new Proxy(
  {},
  {
    has(target, key) {
      return true;
    },
    get(target, prop, receiver) {
      return eval(prop);
    }
  }
);
Object.prototype.__Please_install_the_js_library_for_the_application_to_work = {
  __elm_interop: p
};
