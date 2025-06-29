export function generateSlots(from: string, to: string) {
  const start = new Date(from);
  const end = new Date(to);
  const slots = [{ from: start, to: end }];

  while (start < end) {
    const slotStart = new Date(start);
    const slotEnd = new Date(start.getTime() + 15 * 60 * 1000); // 15 min
    if (slotEnd > end) break;

    slots.push({ from: slotStart, to: slotEnd });
    start.setTime(slotEnd.getTime());
  }
  slots.shift();
  return slots;
}
