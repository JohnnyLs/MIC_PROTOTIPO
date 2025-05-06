import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PreguntaService } from '../services/pregunta.service';
import { Pregunta } from '../models/pregunta.model';

@Component({
  selector: 'app-preguntas',
  templateUrl: './preguntas.component.html',
  styleUrls: ['./preguntas.component.css'],
  imports: [CommonModule, FormsModule],
  standalone: true
})
export class PreguntasComponent implements OnInit {
  preguntas: Pregunta[] = [];
  filteredPreguntas: Pregunta[] = [];
  searchTerm: string = '';
  selectedCategoria: string = '';
  categorias: string[] = [];
  showForm: boolean = false;
  isEditing: boolean = false;
  currentPregunta: Pregunta = {
    textoPregunta: '',
    opciones: '',
    respuestaCorrecta: '',
    dificultad: '',
    tiempoLimite: 0,
    categoria: '',
    costoEnergia: 0,
    estado: 'activo'
  };

  constructor(private preguntaService: PreguntaService) {}

  ngOnInit(): void {
    this.loadPreguntas();
  }

  loadPreguntas(): void {
    this.preguntaService.obtenerTodasLasPreguntas().subscribe({
      next: (preguntas) => {
        this.preguntas = preguntas;
        this.filteredPreguntas = [...this.preguntas];
        this.extractCategorias();
        this.filterPreguntas();
      },
      error: (err) => {
        console.error('Error al cargar las preguntas:', err);
      }
    });
  }

  extractCategorias(): void {
    this.categorias = [...new Set(this.preguntas.map(p => p.categoria))].sort();
  }

  filterPreguntas(): void {
    this.filteredPreguntas = this.preguntas.filter(pregunta => {
      const matchesSearch = pregunta.textoPregunta.toLowerCase().includes(this.searchTerm.toLowerCase());
      const matchesCategoria = this.selectedCategoria ? pregunta.categoria === this.selectedCategoria : true;
      return matchesSearch && matchesCategoria;
    });
  }

  onSearchChange(): void {
    this.filterPreguntas();
  }

  onCategoriaChange(): void {
    this.filterPreguntas();
  }

  openCreateForm(): void {
    this.showForm = true;
    this.isEditing = false;
    this.currentPregunta = {
      textoPregunta: '',
      opciones: '',
      respuestaCorrecta: '',
      dificultad: '',
      tiempoLimite: 0,
      categoria: '',
      costoEnergia: 0,
      estado: 'activo'
    };
  }

  openEditForm(pregunta: Pregunta): void {
    this.showForm = true;
    this.isEditing = true;
    this.currentPregunta = { ...pregunta };
  }

  savePregunta(): void {
    if (this.isEditing) {
      this.preguntaService.actualizarPregunta(this.currentPregunta.idPregunta!, this.currentPregunta).subscribe({
        next: (updatedPregunta) => {
          const index = this.preguntas.findIndex(p => p.idPregunta === updatedPregunta.idPregunta);
          this.preguntas[index] = updatedPregunta;
          this.filterPreguntas();
          this.showForm = false;
        },
        error: (err) => {
          console.error('Error al actualizar la pregunta:', err);
        }
      });
    } else {
      this.preguntaService.crearPregunta(this.currentPregunta).subscribe({
        next: (newPregunta) => {
          this.preguntas.push(newPregunta);
          this.filterPreguntas();
          this.showForm = false;
        },
        error: (err) => {
          console.error('Error al crear la pregunta:', err);
        }
      });
    }
  }

  deletePregunta(id: number): void {
    if (confirm('¿Estás seguro de que deseas eliminar esta pregunta?')) {
      this.preguntaService.eliminarPregunta(id).subscribe({
        next: () => {
          this.preguntas = this.preguntas.filter(p => p.idPregunta !== id);
          this.filterPreguntas();
        },
        error: (err) => {
          console.error('Error al eliminar la pregunta:', err);
        }
      });
    }
  }

  toggleEstado(pregunta: Pregunta): void {
    const nuevoEstado: 'activo' | 'inactivo' = pregunta.estado === 'activo' ? 'inactivo' : 'activo';
    const updatedPregunta: Pregunta = { ...pregunta, estado: nuevoEstado };
    this.preguntaService.actualizarPregunta(pregunta.idPregunta!, updatedPregunta).subscribe({
      next: (response) => {
        pregunta.estado = response.estado;
        this.filterPreguntas();
      },
      error: (err) => {
        console.error('Error al cambiar el estado de la pregunta:', err);
      }
    });
  }

  cancelForm(): void {
    this.showForm = false;
  }
}