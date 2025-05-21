import { Component, OnInit } from '@angular/core';
import { AuthService } from './services/auth.service';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { JugadorService } from './services/jugador.service';
import { Jugador, Partida } from './models/jugador.model';
import { FormsModule } from '@angular/forms';
import { PreguntasComponent } from './preguntas/preguntas.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { Subject } from 'rxjs';

@Component({
  selector: 'app-main',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  imports: [CommonModule, FormsModule, PreguntasComponent, DashboardComponent],
  standalone: true,
})
export class AppComponent implements OnInit {
  jugadores: Jugador[] = [];
  filteredJugadores: Jugador[] = [];
  searchTerm: string = '';
  activeTab: 'reportes' | 'preguntas' | 'dashboard' = 'reportes';
  tabChangeSubject = new Subject<string>(); // Subject para notificar cambios de pestaña

  constructor(
    private authService: AuthService,
    private router: Router,
    private jugadorService: JugadorService
  ) {}

  ngOnInit(): void {
    this.loadJugadores();
  }

  loadJugadores(): void {
    this.jugadorService.getJugadores().subscribe({
      next: (jugadores) => {
        this.jugadores = jugadores.map(jugador => ({
          ...jugador,
          nombrePerfil: this.cleanNombrePerfil(jugador.nombrePerfil),
        }));
        this.filteredJugadores = [...this.jugadores];
      },
      error: (err) => {
        console.error('Error al cargar los jugadores:', err);
      },
    });
  }

  cleanNombrePerfil(nombre: string): string {
    try {
      const parsed = JSON.parse(nombre);
      return parsed.nombrePerfil || nombre;
    } catch {
      return nombre.replace(/["\r\n]/g, '').trim();
    }
  }

  filterJugadores(): void {
    const term = this.searchTerm.toLowerCase();
    this.filteredJugadores = this.jugadores.filter(jugador =>
      jugador.nombrePerfil.toLowerCase().includes(term)
    );
  }

  goToPartidaDetail(partida: Partida): void {
    this.router.navigate([`/partida/${partida.idPartida}`]);
  }

  getColorClass(index: number): string {
    const colors = [
      'color-blue',
      'color-green',
      'color-purple',
      'color-orange',
      'color-teal',
    ];
    return colors[index % colors.length];
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  setActiveTab(tab: 'reportes' | 'preguntas' | 'dashboard'): void {
    this.activeTab = tab;
    this.tabChangeSubject.next(tab); // Emitir evento de cambio de pestaña
  }
}