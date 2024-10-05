//
//  CoreDataManager.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//

import Foundation
import CoreData
import UIKit


protocol MovieCoreDataServiceProtocol {
    func storeMovies(movies: [Movie], category: MovieAPIProvider)
    func getMovies(category: MovieAPIProvider) -> ([Movie],[Data?])
    func getMovie(forMovieWithId id: Int) -> (Movie?,Data?)
    func storeMovieImage(_ image: Data, forMovieWithId id: Int, imageType: MovieImageType)
    func updateMovie(withId id: Int, updatedMovie: Movie)
}

// MARK: - CoreDataManager
class MovieCoreDataManager:MovieCoreDataServiceProtocol {

    static let shared = MovieCoreDataManager()
    private let managedContext: NSManagedObjectContext

    private init() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedContext = appDelegate!.persistentContainer.viewContext
    }

    private func saveContext() {
        if managedContext.hasChanges {
            do {
                try managedContext.save()

            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    private func doesMovieExist<T: NSManagedObject>(withId id: Int, ofType type: T.Type) -> Bool {
        let fechRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: type))
        let predicate = NSPredicate(format: "id == %d", id)
        fechRequest.predicate = predicate
        do {
            let count = try managedContext.count(for: fechRequest)
            return count > 0
        } catch {
            print("Error checking for existing movie: \(error.localizedDescription)")
            return false
        }
    }
    private func createEntity(from movie: Movie) -> MovieEntity {
        let movieEntity = MovieEntity(context: managedContext)
        movieEntity.id = Int64(movie.id)
        movieEntity.overview = movie.overview
        movieEntity.releaseDate = movie.releaseDate
        movieEntity.title = movie.title
        movieEntity.voteAverage = movie.voteAverage
        movieEntity.voteCount = Int64(movie.voteCount)
        return movieEntity
    }

    func storeMovies(movies: [Movie], category: MovieAPIProvider){
        for movie in movies {
            if doesMovieExist(withId: movie.id, ofType: MovieEntity.self) {
                print("Movie with title '\(movie.title)' already exists in category '\(String(describing: category))'.")
            } else {
                let movieEntity = createEntity(from: movie)
                movieEntity.category = category.path
                managedContext.insert(movieEntity)
                print("Inserted movie: \(movie.title) in category '\(String(describing: category))'.")
            }

        }
        saveContext()
    }
    func getMovies(category: MovieAPIProvider) -> ([Movie],[Data?]) {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.path)

        do {
            let moviesObject = try managedContext.fetch(fetchRequest)
            var movies: [Movie] = []
            var images: [Data?] = []
            for movie in moviesObject {
                movies.append(createMovieFromEntity(movie))
                images.append(movie.posterImage)
            }
            return (movies,images)
        } catch {
            print("Error fetching movies: \(error)")
            return ([],[])
        }
    }

    func getMovie(forMovieWithId id: Int) -> (Movie?,Data?) {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let moviesObject = try managedContext.fetch(fetchRequest)
            if let movieObject = moviesObject.first{
                let movie = createMovieFromEntity(movieObject)
                return (movie,movieObject.backdropImage)
            }else {
                print("no cached movie With Id \(id)")
                return (nil,nil)
            }
        } catch {
            print("Error fetching movie: \(error)")
            return (nil,nil)
        }

    }

    func storeMovieImage(_ image: Data, forMovieWithId id: Int, imageType: MovieImageType) {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let moviesObject = try managedContext.fetch(fetchRequest)
            if let movieObject = moviesObject.first {
                switch imageType {
                case .backdrop:
                    movieObject.backdropImage = image
                case .poster:
                    movieObject.posterImage = image
                }
            }
        } catch {
            print("Error fetching movie: \(error)")
        }
        saveContext()
    }
    func updateMovie(withId id: Int, updatedMovie: Movie) {
            let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)

            do {
                let moviesObjects = try managedContext.fetch(fetchRequest)
                for movieObject in moviesObjects {
                        movieObject.budget = Int64(updatedMovie.budget ?? 0)
                        movieObject.revenue = Int64(updatedMovie.revenue ?? 0)
                        movieObject.runtime = Int64(updatedMovie.runtime ?? 0)
                        movieObject.tagline = updatedMovie.tagline
                       movieObject.genres = updatedMovie.genres as? NSObject
                        saveContext()
                        print("Updated movie: \(updatedMovie.title)")
                    }
            } catch {
                print("Error updating movie: \(error.localizedDescription)")
            }
        }

    private func createMovieFromEntity(_ movie:MovieEntity)-> Movie {
        return Movie(
            revenue: Int(movie.revenue),
            budget: Int(movie.budget),
            adult: movie.adult,
            backdropPath: "",
            id: Int(movie.id),
            originalLanguage: movie.originalLanguage ?? "",
            overview: movie.overview ?? "",
            popularity: movie.popularity ,
            posterPath: "",
            releaseDate: movie.releaseDate ?? "",
            title: movie.title ?? "" ,
            voteAverage: movie.voteAverage,
            voteCount: Int(movie.voteCount),
            genres: movie.genres as? [Genre]  ?? [],
            runtime: Int(movie.runtime),
            tagline: movie.tagline
        )
    }

}
