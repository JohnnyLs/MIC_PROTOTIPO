import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class EstadisticasService {
  private apiUrl = 'http://localhost:8082/api/dashboard';

  constructor(private http: HttpClient) {}

  getTopJugadores(limit: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/top-jugadores/${limit}`);
  }

  getTopJugadoresCategoria(limit: number): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/top-jugadores-categoria/${limit}`);
  }

  getHistoricoPartidas(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/historico-partidas`);
  }
}