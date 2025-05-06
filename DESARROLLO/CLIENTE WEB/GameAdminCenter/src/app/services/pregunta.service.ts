import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Pregunta } from '../models/pregunta.model';

@Injectable({
  providedIn: 'root'
})
export class PreguntaService {
  private apiUrl = 'http://localhost:8082/api/preguntas';

  constructor(private http: HttpClient) {}

  // Obtener todas las preguntas
  obtenerTodasLasPreguntas(): Observable<Pregunta[]> {
    return this.http.get<Pregunta[]>(this.apiUrl);
  }

  // Obtener una pregunta por ID
  obtenerPreguntaPorId(id: number): Observable<Pregunta> {
    return this.http.get<Pregunta>(`${this.apiUrl}/${id}`);
  }

  // Crear una nueva pregunta
  crearPregunta(pregunta: Pregunta): Observable<Pregunta> {
    return this.http.post<Pregunta>(this.apiUrl, pregunta);
  }

  // Actualizar una pregunta existente
  actualizarPregunta(id: number, pregunta: Pregunta): Observable<Pregunta> {
    return this.http.put<Pregunta>(`${this.apiUrl}/${id}`, pregunta);
  }

  // Eliminar una pregunta
  eliminarPregunta(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}