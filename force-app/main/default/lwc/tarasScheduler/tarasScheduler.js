import { LightningElement, track } from 'lwc';

export default class SimpleCalendarScheduler extends LightningElement {
	days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  	hours = ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'];

	users = ['Taras', 'Marian', 'Vasyl']
	handleClick(){
		alert(4)
	}
	connectedCallback(){
		this.getFormattedDatesOfWeek();
	}


	getFormattedDatesOfWeek() {
		const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
		const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
	  
		const today = new Date();
		const currentDayOfWeek = today.getDay(); // Поточний день тижня (0 - Неділя, 1 - Понеділок, ..., 6 - Субота)
		const currentDayOfMonth = today.getDate(); // Поточний день місяця
		const currentMonth = today.getMonth(); // Поточний місяць
	  
		// Знаходимо перший день поточного тижня (понеділок)
		const firstDayOfWeek = new Date(today);
		firstDayOfWeek.setDate(currentDayOfMonth - currentDayOfWeek + 1);
	  
		// Формуємо масив з датами тижня у вказаному форматі
		const formattedDatesOfWeek = [];
		for (let i = 0; i < 7; i++) {
		  const date = new Date(firstDayOfWeek);
		  date.setDate(firstDayOfWeek.getDate() + i);
		  const formattedDate = `${daysOfWeek[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}`;
		  formattedDatesOfWeek.push(formattedDate);
		}
	  
		this.days = formattedDatesOfWeek;
	  }
}