import React, { useState, useEffect } from "react";
import { useAuth } from "../contexts/AuthContext";
import axiosClient from "../api/axiosClient";
import { Link } from "react-router-dom";
import NavBar from "../components/NavBar";

const ViewerHome = () => {
  const { user, logout } = useAuth();
  const [recommendations, setRecommendations] = useState([]);
  const [recentFeedback, setRecentFeedback] = useState([]);
  const [latestSeries, setLatestSeries] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    axiosClient
      .get("/viewer/recommendations")
      .then((data) => setRecommendations(data.slice(0, 4)))
      .catch((err) => setError(err.error || "Could not fetch recommendations"));

    axiosClient
      .get("/viewer/my-feedback")
      .then((data) => setRecentFeedback(data.slice(0, 4)))
      .catch(() => {});

    axiosClient
      .get("/viewer/series")
      .then((data) => {
        const sorted = [...data].sort((a, b) => b.SID - a.SID);
        setLatestSeries(sorted.slice(0, 4));
      })
      .catch(() => {});
  }, []);

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Welcome, {user.display_name}!</h1>
            {/* <div className="inline-actions">
                            <Link className="btn btn-secondary" to="/viewer/series">All Series</Link>
                            <Link className="btn btn-secondary" to="/viewer/my-feedback">My Feedback</Link>
                            <Link className="btn btn-secondary" to="/viewer/profile">Profile</Link>
                            <button className="btn btn-danger" onClick={logout}>Logout</button>
                        </div> */}
          </div>
          <div className="home-sections section">
            <div className="home-section-card">
              <h3>Top Recommended</h3>
              {error && <p className="muted">{error}</p>}
              {recommendations.length ? recommendations.map((series) => (
                <div key={series.SID} style={{ marginBottom: "12px" }}>
                  <h4 className="item-title">
                    <Link to={`/viewer/series/${series.SID}`}>{series.SNAME}</Link>
                  </h4>
                  <p className="item-meta">Language: {series.ORI_LANG}</p>
                  <p className="item-meta">Avg. Rating: {parseFloat(series.avg_rating).toFixed(2)}</p>
                </div>
              )) : <p className="muted">No recommendations yet.</p>}
            </div>

            <div className="home-section-card">
              <h3>My Recent Feedback</h3>
              {recentFeedback.length ? recentFeedback.map((f) => (
                <div key={`${f.SID}-${f.FDATE}`} style={{ marginBottom: "12px" }}>
                  <h4 className="item-title"><Link to={`/viewer/series/${f.SID}`}>{f.SNAME}</Link></h4>
                  <p className="item-meta">Rated {f.RATE} · {f.FDATE}</p>
                  <p className="item-meta">{f.FTEXT}</p>
                </div>
              )) : <p className="muted">No feedback yet.</p>}
            </div>

            <div className="home-section-card">
              <h3>New Releases</h3>
              {latestSeries.length ? latestSeries.map((s) => (
                <div key={s.SID} style={{ marginBottom: "12px" }}>
                  <h4 className="item-title"><Link to={`/viewer/series/${s.SID}`}>{s.SNAME}</Link></h4>
                  <p className="item-meta">Language: {s.ORI_LANG} · Episodes: {s.NEPISODES}</p>
                </div>
              )) : <p className="muted">No recent releases.</p>}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default ViewerHome;
