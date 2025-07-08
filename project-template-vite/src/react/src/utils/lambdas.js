export const compose =
  (...actions) =>
  (val) =>
    actions.reduceRight((result, action) => action(result), val)
